#!/bin/bash

### ---
### INSTALAR O KIBANA.
### https://www.elastic.co/guide/en/kibana/8.9/rpm.html
### ---

### --- Instalar o pacote Kibana.

sudo dnf install kibana -y

### --- Configurar a ligação de porta do Kibana para usar qualquer IP 
# ou um IP específico. No arquivo '/etc/kibana/kibana.yml', encontrar a linha 
# "server.host" e editar seu valor.

sudo sed -i 's/#server.host: "localhost"/server.host: "192.168.121.200"/' /etc/kibana/kibana.yml

### --- Ativar e iniciar o serviço Kibana.

sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana

### --- Criar com o "openssl" um usuário 'Kibana administrativo' que será usado 
# para acessar a interface web do Kibana. O comando criará o usuário e a senha 
# e os armazenará no arquivo "/etc/nginx/htpasswd.users". Salva o output
# para um arquivo.

echo "kibanaadmin:$(openssl passwd -apr1 'kibana123')" | sudo tee -a /etc/nginx/htpasswd.users > /elk/remote_file_output/passwd_kibana.txt

### --- Permitir o tráfego na porta TCP 5601 para ter acesso a interface web do 
# Kibana de outro computador.

sudo firewall-cmd --add-port=5601/tcp
sudo firewall-cmd --add-port=5601/tcp --permanent
sudo firewall-cmd --reload

### --- Criar o arquivo de bloco "/etc/nginx/conf.d/elk.conf" do servidor Nginx.
# Dessa forma não será solicitado o nome de usuário e senha porque será lido 
# o arquivo "htpasswd.users" momentaneamente onde foi armazenado o usuário e a 
# senha do 'kibana administrador'.

sudo bash -c 'cat > /etc/nginx/conf.d/elk.conf << EOF
server {
    listen 80;

    server_name elk;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://0.0.0.0:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF'

### --- Verificar se a configuração do Nginx tem erro de sintaxe.
# Executar o comando nginx -t e armazena a saída em uma variável.
# O Nginx escreve a saída de erro (stderr) para o arquivo, e não a saída padrão (stdout).
# Usar o operador de redirecionamento 2> em vez de >.

sudo nginx -t 2> /elk/remote_file_output/output_config_nginx.txt

### --- Ativar e reiniciar o serviço Nginx.

sudo systemctl enable nginx.service
sudo systemctl restart nginx

### --- Acessar o painel di Kibana em seu navegador em "http://server-IP:5601".

#http://localhost:5601 ou http://IP.com:5601
