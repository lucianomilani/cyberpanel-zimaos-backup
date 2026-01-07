Execute este bloco no terminal do CyberPanel:

# 1. Criar a pasta de organização
mkdir -p /root/scripts-backup

# 2. Criar os ficheiros vazios
touch /root/scripts-backup/backup_remoto_expert.sh
touch /root/scripts-backup/README.md

# 3. Aplicar permissões de execução no script
chmod +x /root/scripts-backup/backup_remoto_expert.sh

# 4. Criar o atalho no sistema para que o comando funcione globalmente
ln -sf /root/scripts-backup/backup_remoto_expert.sh /usr/local/bin/backup_remoto_expert.sh

echo "--------------------------------------------------------"
echo "Estrutura preparada com sucesso!"
echo "1. Abra o ficheiro: nano /root/scripts-backup/backup_remoto_expert.sh"
echo "2. Cole o código que copiou do seu GIT."
echo "3. Guarde (CTRL+O, Enter) e saia (CTRL+X)."
echo "--------------------------------------------------------"
