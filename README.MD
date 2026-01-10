🛡️ Unified Backup Monitor (CyberPanel & CloudPanel)
Script leve para monitorizar a integridade dos backups e enviar relatórios formatados para o Telegram. Otimizado para storage remoto via SFTP (ZimaOS).

🚀 Como Instalar
1. Descarregar o Script
Escolha o comando de acordo com o seu painel:

Para CloudPanel:

Bash

curl -o /usr/local/bin/backup_report.sh https://raw.githubusercontent.com/lucianomilani/cyberpanel-zimaos-backup/main/report_cloudpanel.sh
Para CyberPanel:

Bash

curl -o /usr/local/bin/backup_report.sh https://raw.githubusercontent.com/lucianomilani/cyberpanel-zimaos-backup/main/report_cyberpanel.sh
2. Configurar e Dar Permissão
Edite o ficheiro para inserir o seu Token e ChatID do Telegram:

Bash

nano /usr/local/bin/backup_report.sh
chmod +x /usr/local/bin/backup_report.sh
3. Agendar no Cron
Configure para correr todos os domingos às 09:00:

Bash

(crontab -l 2>/dev/null; echo "00 09 * * 0 /usr/local/bin/backup_report.sh > /dev/null 2>&1") | crontab -
📊 Exemplo do Relatório
🤖 Relatório de Integridade: Servidor-Alpha

📌 ESTADO: 🟢 SAUDÁVEL ℹ️ Detalhe: Backup confirmado via arquivo físico. 📝 Evidência: backup_site_2026.tar.gz 📍 Destino: ZimaOS (TechX Storage)

🛠️ Configuração ZimaOS (SFTP)
Os scripts validam o envio para o storage configurado em:

Host: techx.es

Port: 2993

Path: /media/storage_8tb/TechX/

Repo: lucianomilani/cyberpanel-zimaos-backup

O que mudou?
Nome Único: Sugeri usar backup_report.sh no destino para facilitar os comandos, independentemente do painel.

Instalação via CURL: Mais limpo e moderno.

Sem "Encheção de chouriço": Focado apenas na execução.

Era esta estrutura mais "limpa" que pretendia? Se sim, pode copiar exatamente o que está entre as linhas tracejadas para o seu GitHub.
