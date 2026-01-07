# Sistema de Backup Especializado - CyberPanel para ZimaOS/CasaOS
Este script automatiza o backup de ficheiros e bases de dados (WordPress/Moodle) e sincroniza com o ZimaOS/CasaOS (remoto)

## Fluxo
1. Deteção de DB via wp-config.php ou config.php.
2. Compactação Tar.gz.
3. Envio via Rsync (Porta 2993).
4. Retenção de 14 dias + 1 Mensal no destino.
5. Retenção de 7 dias no servidor CyberPanel

## Apoio

Ver istruções no Docs
Script de apoio e script de execução na pasta scripts
