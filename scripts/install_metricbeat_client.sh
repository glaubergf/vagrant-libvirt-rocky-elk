#!/bin/bash

### -----
### INSTALAR O BEAT (FILEBEAT/METRICBEAT) NO CLIENTE DEBIAN
### https://www.elastic.co/guide/en/beats/libbeat/current/beats-reference.html
### -----

### --- Copiar o certificado SSL do servidor Rocky Linux 9 para o cliente 
# Debian 12 usando o comando scp.

sudo scp elk@192.168.121.200:/etc/pki/tls/certs/logstash-forwarder.crt /etc/ssl/certs/

### --- Copiar o script de instalação do Beats para o diretório home do usuário.

#scp elk@192.168.121.200:/elk/scripts/script_install_metricbeat_client.sh /home/$USER/

### --- Copiar o arquivo do password do 'elastic' para o diretório home do usuário.

#scp elk@192.168.121.200:/elk/remote_file_output/passwd_elastic.txt /home/$USER/

### --- Importar a chave GPG pública do Elasticsearch para o gerenciador de 
# pacotes deb na máquina cliente.

curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor | sudo tee /usr/share/keyrings/elasticsearch.gpg > /dev/null 2>&1

### --- Criar o repositório para o Beat.

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/elasticsearch.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

#### --- Instalar o pacote "apt-transport-https" caso não esteja instalado.

sudo apt install apt-transport-https -y

#### --- Atualizar repositório, habilitar, instalar, e iniciar o pacote Beat.

sudo apt update
sudo apt install metricbeat -y
sudo systemctl enable metricbeat
sudo systemctl start metricbeat

### --- Alterar o arquivo "/etc/metricbeat/metricbeat.yml" para definir as 
# informações de conexão em cada seção conforme abaixo.

# - Alterar o 'host' do Elasticsearch na seção output.elasticsearch.

sudo sed -i 's/hosts: \["localhost:9200"\]/\hosts: \["192.168.121.200:9200"\]/' /etc/metricbeat/metricbeat.yml

# - Descomentar o 'username' na seção output.elasticsearch.

sudo sed -i 's/#username: "elastic"/username: "elastic"/' /etc/metricbeat/metricbeat.yml

# - Descomentar e alterar o valor de 'password' na seção output.elasticsearch:

sudo sed -i 's/#password: "changeme"/password: "changeme"/' /etc/metricbeat/metricbeat.yml

PASSWD_ELASTIC=$(grep "New value:" passwd_elastic.txt | awk '{print $3}')

sudo sed -i "s/password: \"changeme\"/password: \"$PASSWD_ELASTIC\"/" /etc/metricbeat/metricbeat.yml

# - Descomentar e alterar o valor de 'host' na seção setup.kibana:

sudo sed -i 's/#host: "localhost:5601"/host: "192.168.121.200:5601"/' /etc/metricbeat/metricbeat.yml

### --- Habilitar o módulo system.

sudo metricbeat modules enable system

### --- Alterar as configurações no arquivo "/etc/metricbeat/modules.d/system.yml", 
# deve ser ativado pelo menos um conjunto de arquivos.
    

### --- Reiniciar o Metricbeat

#O comando setup carrega os painéis do Kibana. Se os painéis já estiverem configurados, omita este comando.

sudo metricbeat setup
sudo systemctl restart metricbeat
