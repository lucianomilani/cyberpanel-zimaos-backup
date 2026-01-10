🛡️ Sistema Unificado de Monitorização de Backups (TechX)Integração CyberPanel/CloudPanel para ZimaOS via TelegramEste documento detalha a implementação de um sistema de relatórios automáticos para validar a integridade de backups em ambientes multi-servidor, enviando os dados para um armazenamento centralizado (ZimaOS) e notificando o administrador via Telegram.📋 Arquitetura do SistemaO sistema baseia-se em scripts Bash leves que verificam três camadas de dados antes de reportar o estado:Camada de Processo: Analisa logs de erro em tempo real.Camada Física: Verifica se o ficheiro .tar.gz foi efetivamente criado nas últimas 24h.Camada de Notificação: Envia um relatório formatado via API do Telegram.🛠️ Scripts de Monitorização1. Script para CloudPanel (Ubuntu/Debian)Específico para detetar atividades do utilizador clp e comandos clpctl.Bashcat << 'EOF' > /usr/local/bin/report_cloudpanel.sh
#!/bin/bash
# --- CONFIGURAÇÕES ---
TOKEN="7999220153:AAG16TzAOZ5rCUAIY_4pL2EhKanhonVrtok"
CHAT_ID="-1003521688767"
HOSTNAME=$(hostname)

# 1. BUSCA DE DADOS
LOG_ERRORS=$(journalctl --since "24 hours ago" | grep "create_backup.sh" | grep -iE "error|failed|fatal" | tail -n 1)
LOG_ACTIVITY=$(journalctl --since "24 hours ago" | grep -iE "create_backup|clpctl" | grep -ivE "session|pam_unix|sudo" | tail -n 1)

# 2. LÓGICA DE ESTADO
if [[ -n "$LOG_ERRORS" ]]; then
    ESTADO="🔴 ERRO"
    DETALHE="Falha real detectada no script de backup."
    EVIDENCIA=$(echo "$LOG_ERRORS" | sed 's/[<>&]//g' | cut -c 1-150)
elif [[ -n "$LOG_ACTIVITY" ]]; then
    ESTADO="🟢 SAUDÁVEL"
    DETALHE="Atividade de backup validada via sistema."
    EVIDENCIA=$(echo "$LOG_ACTIVITY" | sed 's/[<>&]//g' | cut -c 1-150)
else
    BKP_FILES=$(find /home/clp/backups/ -name "*.tar.gz" -mmin -1440 2>/dev/null | head -n 1)
    if [[ -n "$BKP_FILES" ]]; then
        ESTADO="🟢 SAUDÁVEL"
        DETALHE="Backup confirmado via arquivo físico."
        EVIDENCIA="Arquivo: $(basename $BKP_FILES)"
    else
        ESTADO="⚪ AGUARDANDO"
        DETALHE="Sem atividade nas últimas 24h."
        EVIDENCIA="Verificar agendamento no painel."
    fi
fi

# 3. ENVIO TELEGRAM
MENSAGEM="<b>🤖 Relatório de Integridade: $HOSTNAME</b>%0A------------------------------------%0A📌 <b>ESTADO:</b> $ESTADO%0Aℹ️ <b>Detalhe:</b> $DETALHE%0A------------------------------------%0A📝 <b>Evidência:</b>%0A<code>$EVIDENCIA</code>%0A📍 <b>Destino:</b> ZimaOS (TechX Storage)"
curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID" -d "text=$MENSAGEM" -d "parse_mode=HTML"
EOF
chmod +x /usr/local/bin/report_cloudpanel.sh
2. Script para CyberPanel (CentOS/Ubuntu)Focado na estrutura de pastas /home/backup e logs do CyberCP.Bashcat << 'EOF' > /usr/local/bin/report_cyberpanel.sh
#!/bin/bash
# --- CONFIGURAÇÕES ---
TOKEN="7999220153:AAG16TzAOZ5rCUAIY_4pL2EhKanhonVrtok"
CHAT_ID="-1003521688767"
HOSTNAME="$(hostname) (CyberPanel)"

# 1. BUSCA DE DADOS (Verifica arquivos físicos gerados)
BKP_FILE=$(find /home/ -path "*/backup/*.tar.gz" -mmin -1440 2>/dev/null | head -n 1)

# 2. LÓGICA DE ESTADO
if [[ -n "$BKP_FILE" ]]; then
    ESTADO="🟢 SAUDÁVEL"
    DETALHE="Backup local concluído com sucesso."
    EVIDENCIA="Arquivo: $(basename $BKP_FILE)"
else
    ESTADO="⚪ AGUARDANDO"
    DETALHE="Backup local não encontrado ou ainda em processamento (RUNNING)."
    EVIDENCIA="Verificar agendamento (Padrão: 03:00)."
fi

# 3. ENVIO TELEGRAM
MENSAGEM="<b>🤖 Relatório de Integridade: $HOSTNAME</b>%0A------------------------------------%0A📌 <b>ESTADO:</b> $ESTADO%0Aℹ️ <b>Detalhe:</b> $DETALHE%0A------------------------------------%0A📝 <b>Evidência:</b>%0A<code>$EVIDENCIA</code>%0A📍 <b>Destino:</b> ZimaOS (TechX Storage)"
curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID" -d "text=$MENSAGEM" -d "parse_mode=HTML"
EOF
chmod +x /usr/local/bin/report_cyberpanel.sh

⏰ Agendamento Automático (Crontab)Configuração para envio semanal (Domingos às 09:00), garantindo que todos os backups da madrugada já terminaram.PainelComando de Instalação CronCloudPanel(crontab -l 2>/dev/null; echo "00 09 * * 0 /usr/local/bin/report_cloudpanel.sh > /dev/null 2>&1") | crontab -CyberPanel(crontab -l 2>/dev/null; echo "00 09 * * 0 /usr/local/bin/report_cyberpanel.sh > /dev/null 2>&1") | crontab -📁 Gestão do ZimaOS (Storage Externo)Todos os backups são enviados para o servidor central através de SFTP.Host: techx.esPorta: 2993 (SFTP Port)Caminho Base: /media/storage_8tb/TechX/Estrutura de Pastas Sugerida:/scmm/ -> Backups do Misericórdia Mogadouro/mail/ -> Backups do TechX Mail/alpha/ -> Backups do Servidor Alpha/ts/ -> Backups da TS-Engenharia💡 Notas de SegurançaChaves SSH: Recomenda-se o uso de chaves SSH (ssh-copy-id -p 2993) entre as VPS e o ZimaOS para evitar o uso de senhas em texto limpo.Tokens: Antes de partilhar estes scripts publicamente, remova o TOKEN do Telegram e o CHAT_ID.

Desenvolvido por Luciano Milani
