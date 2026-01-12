Sistema de Backup Especializado: CyberPanel para ZimaOS/CasaOS
Sistema automatizado de backup "Full Stack" (Arquivos + SQL) desenhado para superar as limitações do motor nativo do CyberPanel, com suporte nativo para aplicações WordPress e Moodle.

📋 Visão Geral

O script realiza a identificação dinâmica de bases de dados, compactação de ficheiros e sincronização remota com política de retenção inteligente.

🚀 Funcionalidades

Deteção Universal de DB: Localiza bases de dados lendo diretamente o wp-config.php (WordPress) ou config.php (Moodle).
Backup Atómico: Cada site é empacotado individualmente com a sua respectiva base de dados SQL.
Retenção Local (7 Dias): Auto-limpeza do armazenamento local para evitar saturação do disco SSD.
Retenção Remota Inteligente:
Mantém os últimos 14 dias de backups diários.
Preserva automaticamente o backup do dia 01 de cada mês como arquivo histórico permanente.
Transferência Segura: Sincronização via Rsync sobre SSH (Porta 2993).

🛠️ Estrutura de Ficheiros

backup_remoto_expert.sh: Script principal de automação (localizado em /root/scripts-backup/).
/usr/local/bin/backup_remoto_expert.sh: Link simbólico para execução global.
/root/.my.cnf: Ficheiro de credenciais MySQL para exportação segura sem prompts de password.
/var/log/backup_custom.log: Registo de logs para auditoria.

⚙️ Configuração do Fluxo

1. Requisitos
Chave SSH pública do servidor Web autorizada no ZimaOS/CasaOS (authorized_keys).
Ficheiro .my.cnf formatado corretamente com grupos [client] e [mysqldump].
2. Automação (Cron)
O script está configurado para execução diária às 03:00 AM:
