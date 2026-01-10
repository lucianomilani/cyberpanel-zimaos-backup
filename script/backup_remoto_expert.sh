#!/bin/bash

###############################################################################
# SISTEMA DE BACKUP ESPECIALIZADO: CYBERPANEL -> ZIMAOS/SFTP
# Autor: Luciano Milani
# Funcionalidades: Full Stack (Files + SQL), GFS Retention, Telegram Notify
###############################################################################

# --- 1. CONFIGURAÇÕES DE NOTIFICAÇÃO (ANONIMIZADO) ---
TELEGRAM_TOKEN="SEU_TOKEN_AQUI"
TELEGRAM_CHAT_ID="SEU_CHAT_ID_AQUI"

# --- 2. CONFIGURAÇÕES DE ACESSO REMOTO ---
DESTINO_IP="seu.dominio.ou.ip"
DESTINO_USER="seu_utilizador"
DESTINO_PORTA="2993"
PASTA_DESTINO_REMOTO="/media/storage_8tb/TechX/alpha"

# --- 3. CONFIGURAÇÕES LOCAIS ---
PASTA_LOCAL="/home/backup"
DATA_ATUAL=$(date +%Y-%m-%d)
HOSTNAME=$(hostname)
LOG_FILE="/var/log/backup_custom.log"

# --- FUNÇÃO: ENVIO TELEGRAM ---
enviar_telegram() {
    local mensagem="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "parse_mode=HTML" \
        -d "text=$mensagem" > /dev/null
}

echo "[$(date)] --- INICIANDO PROCESSO DE BACKUP ---" | tee -a $LOG_FILE
mkdir -p $PASTA_LOCAL

# --- 4. IDENTIFICAÇÃO DINÂMICA E COMPACTAÇÃO ---
# Ignora pastas padrão do sistema
SITES=$(ls /home | grep -vE "backup|backups|cyberpanel|lscache|vmail|docker|ubuntu|root")

for dominio in $SITES; do
    if [[ $dominio == *"."* ]]; then
        USER_OWNER=$(stat -c '%U' /home/$dominio)
        SQL_TEMP="/home/$dominio/db_backup_full.sql"
        TEM_SQL=false
        DB_NAME=""

        # Lógica: WordPress (wp-config) ou Moodle (config.php)
        if [ -f "/home/$dominio/public_html/wp-config.php" ]; then
            DB_NAME=$(grep "DB_NAME" "/home/$dominio/public_html/wp-config.php" | cut -d \' -f 4)
            [ -z "$DB_NAME" ] && DB_NAME=$(grep "DB_NAME" "/home/$dominio/public_html/wp-config.php" | cut -d \" -f 4)
        elif [ -f "/home/$dominio/public_html/config.php" ]; then
            DB_NAME=$(grep "dbname" "/home/$dominio/public_html/config.php" | cut -d \' -f 4)
            [ -z "$DB_NAME" ] && DB_NAME=$(grep "dbname" "/home/$dominio/public_html/config.php" | cut -d \" -f 4)
        else
            # Fallback: Busca DB que contenha o nome do dono do site
            DB_NAME=$(mysql -sN -e "SHOW DATABASES LIKE '%$USER_OWNER%';")
        fi

        # Dump do banco de dados se identificado
        if [ ! -z "$DB_NAME" ]; then
            mysqldump --opt --single-transaction --no-tablespaces "$DB_NAME" > "$SQL_TEMP" 2>/dev/null
            [ -s "$SQL_TEMP" ] && TEM_SQL=true
        fi

        # Compactação (Arquivos + SQL se existir)
        echo "Empacotando: $dominio..." | tee -a $LOG_FILE
        if [ "$TEM_SQL" = true ]; then
            tar -czf "$PASTA_LOCAL/backup-$dominio-$DATA_ATUAL.tar.gz" -C "/home/$dominio" public_html "$(basename $SQL_TEMP)" 2>/dev/null
            rm -f "$SQL_TEMP"
        else
            tar -czf "$PASTA_LOCAL/backup-$dominio-$DATA_ATUAL.tar.gz" -C "/home/$dominio" public_html 2>/dev/null
        fi
    fi
done

# --- 5. SINCRONIZAÇÃO E RETENÇÃO REMOTA ---
echo "Sincronizando com ZimaOS via porta $DESTINO_PORTA..." | tee -a $LOG_FILE

# Cria pasta do dia no destino
ssh -p $DESTINO_PORTA $DESTINO_USER@$DESTINO_IP "mkdir -p $PASTA_DESTINO_REMOTO/$DATA_ATUAL"

# Sincroniza apenas os backups do dia
rsync -avz -e "ssh -p $DESTINO_PORTA" $PASTA_LOCAL/backup-*$DATA_ATUAL.tar.gz $DESTINO_USER@$DESTINO_IP:$PASTA_DESTINO_REMOTO/$DATA_ATUAL/
EXIT_CODE=$?

# Retenção Remota Inteligente: Mantém 14 dias, mas preserva o dia 01 (Mensal)
ssh -p $DESTINO_PORTA $DESTINO_USER@$DESTINO_IP "find $PASTA_DESTINO_REMOTO/* -maxdepth 0 -type d -mtime +14 ! -name '*-*-01' -exec rm -rf {} +"

# --- 6. LIMPEZA LOCAL ---
find $PASTA_LOCAL -name "backup-*.tar.gz" -mtime +7 -delete

# --- 7. RELATÓRIO FINAL (TELEGRAM) ---
if [ $EXIT_CODE -eq 0 ]; then
    STATUS="🟢 <b>SUCESSO</b>"
    DETALHE="Backup Full e sincronização concluídos."
else
    STATUS="🔴 <b>FALHA</b>"
    DETALHE="Erro na sincronização Rsync com ZimaOS."
fi

MSG="<b>🤖 Backup Expert: $HOSTNAME</b>%0A------------------------------------%0A📌 <b>STATUS:</b> $STATUS%0Aℹ️ <b>Info:</b> $DETALHE%0A📅 <b>Data:</b> $DATA_ATUAL%0A📍 <b>Destino:</b> ZimaOS Storage"

enviar_telegram "$MSG"

echo "[$(date)] --- FIM DO PROCESSO (EXIT $EXIT_CODE) ---" | tee -a $LOG_FILE
