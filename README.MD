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


**Para CloudPanel:**

```bash
wget [https://raw.githubusercontent.com/lucianomilani/cyberpanel-zimaos-backup/main/report_cloudpanel.sh](https://raw.githubusercontent.com/lucianomilani/cyberpanel-zimaos-backup/main/report_cloudpanel.sh) -O /usr/local/bin/report_cloudpanel.sh
chmod +x /usr/local/bin/report_cloudpanel.sh

3. Configurar Variáveis
Edita o script escolhido e insere as tuas credenciais:

TOKEN="O_TEU_BOT_TOKEN"
CHAT_ID="O_TEU_CHAT_ID"

⏰ Agendamento (Cron)
Para receber o relatório todos os domingos às 09:00, adiciona a seguinte linha ao teu crontab (crontab -e):

CyberPanel:

Fragmento do código

00 09 * * 0 /usr/local/bin/report_cyberpanel.sh > /dev/null 2>&1
CloudPanel:

Fragmento do código

00 09 * * 0 /usr/local/bin/report_cloudpanel.sh > /dev/null 2>&1

🛠️ Integração com ZimaOS
Os scripts foram desenhados para funcionar com o ZimaOS via SFTP na porta personalizada (ex: 2993). Certifica-te de que a chave SSH do servidor está autorizada no ZimaOS para um fluxo 100% automatizado.


📄 Licença
Distribuído sob a licença MIT. Veja LICENSE para mais informações.

Desenvolvido por Luciano Milani
