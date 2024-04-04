#!/bin/bash

### ---
### INSTALAR O "ELASTICSEARCH.
### https://www.elastic.co/guide/en/elasticsearch/reference/8.12/rpm.html#rpm-repo
### ---

### --- Habilitar e iniciar o firewall.

sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl status firewalld

### --- Adicionar o serviço "http" e "https" recarregar o firewall.

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

### --- Baixar e instalar o "Java" a partir do binário que é uma dependência para 
# o Elastic Stack.

sudo wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.rpm ; sudo rpm -Uvh jdk-21_linux-x64_bin.rpm

### --- Instalar o "Java" do repositório.

#sudo dnf install java-21-openjdk -y

### --- Verificar a versão do Java

java -version

### --- Importar a chave GPG pública do Elasticsearch para o gerenciador de pacotes rpm.

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#### --- Inserir as seguintes linhas no arquivo de configuração do repositório 
# "/etc/yum.repos.d/elasticsearch.repo".

#[elasticsearch]
#name=Elastic repository for 8.x packages
#baseurl=https://artifacts.elastic.co/packages/8.x/yum
#gpgcheck=1
#gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
#enabled=1
#autorefresh=1
#type=rpm-md

echo -e "[elasticsearch]\nname=Elastic repository for 8.x packages\nbaseurl=https://artifacts.elastic.co/packages/8.x/yum\ngpgcheck=1\ngpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch\nenabled=1\nautorefresh=1\ntype=rpm-md" | sudo tee /etc/yum.repos.d/elasticsearch.repo

### --- Atualizar cache do sistema.

sudo dnf clean all
sudo dnf makecache

### --- Instalar o pacote Elasticsearch.

sudo dnf install elasticsearch -y

### --- Habilitar e iniciar o serviço Elasticsearch.

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

### --- Resetar a senha do usuário 'elastic' administrador do elasticsearch e 
# salvar em um arquivo.

sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b > /elk/remote_file_output/passwd_elastic.txt

### --- Editar o arquivo de configuração do Elasticsearch.
# Restringir o acesso externo à instância do Elasticsearch para evitar que alguém 
# leiam os dados ou desliguem o cluster do Elasticsearch por meio da API REST.
# No arquivo '/etc/elasticsearch/elasticsearch.yml', encontrar a linha "network.host", 
# remover o comentário e substituir o valor para "localhost".
# Encontar a linha "xpack.security.enabled" e alterar seu valor para 'false'

sudo sed -i 's/#network.host:.*/network.host: localhost/' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/g' /etc/elasticsearch/elasticsearch.yml

### --- Permita o tráfego através da porta TCP 9200 no firewall.

sudo firewall-cmd --add-port=9200/tcp
sudo firewall-cmd --add-port=9200/tcp --permanent
sudo firewall-cmd --reload

### --- Reiniciar o Elasticsearch para que as alterações tenham efeito."

sudo systemctl daemon-reload
sudo systemctl restart elasticsearch

### --- Verificar se o Elasticsearch responde a solicitações simples por HTTP 
# usando o comando curl e salvar sua saída em um arquivo.

curl -X GET http://localhost:9200 > /elk/remote_file_output/response_to_request_elasticsearch.txt
