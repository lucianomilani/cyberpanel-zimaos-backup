#!/bin/bash

# 1. DEFINIÇÃO DE CAMINHOS
FOLDER="/root/scripts-backup"
SCRIPT_PATH="$FOLDER/backup_remoto_expert.sh"
README_PATH="$FOLDER/README.md"

# 2. CRIAÇÃO DA ESTRUTURA
echo "Criando diretórios e ficheiros..."
mkdir -p $FOLDER

# 3. GERAÇÃO DO SCRIPT DE BACKUP (COM DADOS DE EXEMPLO)
cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash

# --- CONFIGURAÇÕES DE ACESSO (SUBSTITUIR PELOS DADOS REAIS) ---
DESTINO_IP="seu.dominio.ou.ip"
DESTINO_USER="seu_utilizador"
DESTINO_PORTA="sua_porta_ssh"
PASTA_LOCAL="/home/backup"
PASTA_DESTINO_REMOTO="/caminho/no/zimaos/storage"
DATA_ATUAL=$(date +%Y-%m-%d)

echo "[$(date)] --- INICIANDO BACKUP ---"
mkdir -p $PASTA_LOCAL

# Identificação de sites
SITES=$(ls /home | grep -vE "backup|backups|cyberpanel|lscache|vmail|docker|ubuntu|root")

for dominio in $SITES; do
    if [[ $dominio == *"."* ]]; then
        USER_OWNER=$(stat -c '%U' /home/$dominio)
        SQL_TEMP="/home/$dominio/db_backup_full.sql"
        TEM_SQL=false
        DB_NAME=""

        # Lógica WordPress / Moodle
        if [ -f "/home/$dominio/public_html/wp-config.php" ]; then
            DB_NAME=$(grep "DB_NAME" "/home/$dominio/public_html/wp-config.php" | cut -d \' -f 4)
            [ -z "$DB_NAME" ] && DB_NAME=$(grep "DB_NAME" "/home/$dominio/public_html/wp-config.php" | cut -d \" -f 4)
        elif [ -f "/home/$dominio/public_html/config.php" ]; then
            DB_NAME=$(grep "dbname" "/home/$dominio/public_html/config.php" | cut -d \' -f 4)
            [ -z "$DB_NAME" ] && DB_NAME=$(grep "dbname" "/home/$dominio/public_html/config.php" | cut -d \" -f 4)
        else
            DB_NAME=$(mysql -sN -e "SHOW DATABASES LIKE '%$USER_OWNER%';")
        fi

        if [ ! -z "$DB_NAME" ]; then
            mysqldump --opt --single-transaction --no-tablespaces "$DB_NAME" > "$SQL_TEMP" 2>/dev/null
            [ -s "$SQL_TEMP" ] && TEM_SQL=true
        fi

        if [ "$TEM_SQL" = true ]; then
            tar -czf "$PASTA_LOCAL/backup-$dominio-$DATA_ATUAL.tar.gz" -C "/home/$dominio" public_html "$(basename $SQL_TEMP)" 2>/dev/null
            rm -f "$SQL_TEMP"
        else
            tar -czf "$PASTA_LOCAL/backup-$dominio-$DATA_ATUAL.tar.gz" -C "/home/$dominio" public_html 2>/dev/null
        fi
    fi
done

# Sincronização e Retenção Remota (14 dias + Mensal)
ssh -p $DESTINO_PORTA $DESTINO_USER@$DESTINO_IP "mkdir -p $PASTA_DESTINO_REMOTO/$DATA_ATUAL"
rsync -avz --include="backup-*.tar.gz" --exclude="*" -e "ssh -p $DESTINO_PORTA" $PASTA_LOCAL/ $DESTINO_USER@$DESTINO_IP:$PASTA_DESTINO_REMOTO/$DATA_ATUAL/
ssh -p $DESTINO_PORTA $DESTINO_USER@$DESTINO_IP "find $PASTA_DESTINO_REMOTO/* -maxdepth 0 -type d -mtime +14 ! -name '*-*-01' -exec rm -rf {} +"

# Limpeza Local (7 dias)
find $PASTA_LOCAL -name "backup-*.tar.gz" -mtime +7 -delete
find $PASTA_LOCAL -type d -name "01.*" -mtime +7 -exec rm -rf {} +

echo "[$(date)] --- PROCESSO CONCLUÍDO ---"
EOF

# 4. GERAÇÃO DO README.MD (DOCUMENTAÇÃO)
cat << 'EOF' > $README_PATH
# 🛡️ Backup CyberPanel -> ZimaOS/CasaOS
Sistema automatizado com retenção inteligente.

## ⚙️ Configuração
1. Edite o script: `nano /root/scripts-backup/backup_remoto_expert.sh`
2. Altere as variáveis `DESTINO_IP`, `DESTINO_USER`, `DESTINO_PORTA` e `PASTA_DESTINO_REMOTO`.

## 🕒 Agendamento (Cron)
`00 03 * * * /usr/local/bin/backup_remoto_expert.sh >> /var/log/backup_custom.log 2>&1`
EOF

# 5. PERMISSÕES E LINKS
chmod +x $SCRIPT_PATH
ln -sf $SCRIPT_PATH /usr/local/bin/backup_remoto_expert.sh

echo "--------------------------------------------------------"
echo "✅ Estrutura criada com sucesso em: $FOLDER"
echo "✅ Link simbólico criado em: /usr/local/bin/"
echo "--------------------------------------------------------"
