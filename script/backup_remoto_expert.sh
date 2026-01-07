cat << 'EOF' > /usr/local/bin/backup_remoto_expert.sh
#!/bin/bash

# --- CONFIGURAÇÕES ---
DESTINO_IP="SEU-IP-DESTINO"
DESTINO_USER="USER-DESTINO"
DESTINO_PORTA="XXXXX"
PASTA_LOCAL="/home/backup"
PASTA_DESTINO_REMOTO="/PASTA/DESTINO/NOME"
DATA_ATUAL=$(date +%Y-%m-%d)

echo "[$(date)] --- INICIANDO BACKUP UNIVERSAL (WP + MOODLE + CP) ---"
mkdir -p $PASTA_LOCAL

# Lista os sites ignorando pastas do sistema
SITES=$(ls /home | grep -vE "backup|backups|cyberpanel|lscache|vmail|docker|ubuntu|root")

for dominio in $SITES; do
    if [[ $dominio == *"."* ]]; then
        echo "[$(date)] >>> Processando: $dominio"
        
        USER_OWNER=$(stat -c '%U' /home/$dominio)
        SQL_TEMP="/home/$dominio/db_backup_full.sql"
        TEM_SQL=false
        DB_NAME=""

        # 1. TENTATIVA A: Se for WordPress (wp-config.php)
        if [ -f "/home/$dominio/public_html/wp-config.php" ]; then
            DB_NAME=$(grep "DB_NAME" "/home/$dominio/public_html/wp-config.php" | cut -d \' -f 4)
            [ -z "$DB_NAME" ] && DB_NAME=$(grep "DB_NAME" "/home/$dominio/public_html/wp-config.php" | cut -d \" -f 4)
            echo "    -> [WP] DB encontrada: $DB_NAME"

        # 2. TENTATIVA B: Se for Moodle (config.php)
        elif [ -f "/home/$dominio/public_html/config.php" ]; then
            DB_NAME=$(grep "dbname" "/home/$dominio/public_html/config.php" | cut -d \' -f 4)
            [ -z "$DB_NAME" ] && DB_NAME=$(grep "dbname" "/home/$dominio/public_html/config.php" | cut -d \" -f 4)
            echo "    -> [Moodle] DB encontrada: $DB_NAME"

        # 3. TENTATIVA C: Pelo Utilizador Linux (Padrão CyberPanel)
        else
            DB_NAME=$(mysql -sN -e "SHOW DATABASES LIKE '%$USER_OWNER%';")
            [ ! -z "$DB_NAME" ] && echo "    -> [CP User] DB encontrada: $DB_NAME"
        fi

        # 4. EXPORTAÇÃO
        if [ ! -z "$DB_NAME" ]; then
            mysqldump --opt --single-transaction --no-tablespaces "$DB_NAME" > "$SQL_TEMP" 2>/dev/null
            [ -s "$SQL_TEMP" ] && TEM_SQL=true
        fi

        # 5. COMPACTAÇÃO
        if [ "$TEM_SQL" = true ]; then
            tar -czf "$PASTA_LOCAL/backup-$dominio-$DATA_ATUAL.tar.gz" -C "/home/$dominio" public_html "$(basename $SQL_TEMP)" 2>/dev/null
            rm -f "$SQL_TEMP"
            echo "[$(date)] OK: $dominio (Arquivos + SQL)"
        else
            tar -czf "$PASTA_LOCAL/backup-$dominio-$DATA_ATUAL.tar.gz" -C "/home/$dominio" public_html 2>/dev/null
            echo "[$(date)] OK: $dominio (Apenas Arquivos - DB não localizada)"
        fi
    fi
done

# --- 6. ENVIO PARA ZIMAOS/CASAOS ---
echo "[$(date)] Enviando para ZimaOS..."
ssh -p $DESTINO_PORTA $DESTINO_USER@$DESTINO_IP "mkdir -p $PASTA_DESTINO_REMOTO/$DATA_ATUAL"
rsync -avz --include="backup-*.tar.gz" --exclude="*" -e "ssh -p $DESTINO_PORTA" $PASTA_LOCAL/ $DESTINO_USER@$DESTINO_IP:$PASTA_DESTINO_REMOTO/$DATA_ATUAL/

# --- 7. RETENÇÃO NO ZIMAOS/CASAOS (14 DIAS + 1 MENSAL) ---
echo "[$(date)] Aplicando retenção inteligente no ZimaOS..."
ssh -p $DESTINO_PORTA $DESTINO_USER@$DESTINO_IP "find $PASTA_DESTINO_REMOTO/* -maxdepth 0 -type d -mtime +14 ! -name '*-*-01' -exec rm -rf {} +"

# --- 8. LIMPEZA LOCAL (7 DIAS) ---
echo "[$(date)] Limpando backups locais antigos..."
find $PASTA_LOCAL -name "backup-*.tar.gz" -mtime +7 -delete
find $PASTA_LOCAL -type d -name "01.*" -mtime +7 -exec rm -rf {} +

echo "[$(date)] --- PROCESSO CONCLUÍDO COM SUCESSO ---"
EOF
