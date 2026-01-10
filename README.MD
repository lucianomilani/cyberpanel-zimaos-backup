# CyberPanel & CloudPanel Backup Monitoring to ZimaOS

Este repositório contém scripts de monitorização de integridade para backups realizados em painéis **CyberPanel** e **CloudPanel**, com foco no envio para armazenamento externo via SFTP (testado em **ZimaOS**).

## 🚀 Funcionalidades

- **Monitorização Inteligente**: O script verifica a existência física de ficheiros `.tar.gz` gerados nas últimas 24h.
- **Análise de Logs**: Filtra logs de sistema (`stderr.log` ou `journalctl`) para identificar falhas reais.
- **Notificações via Telegram**: Envia relatórios formatados em HTML com estados:
  - 🟢 **SAUDÁVEL**: Backup concluído e verificado.
  - 🔴 **ERRO**: Falha detectada no processo de backup.
  - ⚪ **AGUARDANDO**: Nenhum backup detectado (ainda em processamento ou fora do horário).
- **Multi-Painel**: Versões específicas para a estrutura de pastas do CyberPanel e CloudPanel.

## 📦 Instalação

### 1. Preparação
Cria um bot no Telegram através do [@BotFather](https://t.me/botfather) e obtém o teu `CHAT_ID`.

### 2. Configuração no Servidor
Escolhe o script adequado ao teu painel e guarda-o em `/usr/local/bin/`.

**Para CyberPanel:**
```bash
wget [https://raw.githubusercontent.com/lucianomilani/cyberpanel-zimaos-backup/main/report_cyberpanel.sh](https://raw.githubusercontent.com/lucianomilani/cyberpanel-zimaos-backup/main/report_cyberpanel.sh) -O /usr/local/bin/report_cyberpanel.sh
chmod +x /usr/local/bin/report_cyberpanel.sh
