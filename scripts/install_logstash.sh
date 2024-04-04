#!/bin/bash

### -----
### INSTALAR O LOGSTASH
### https://www.elastic.co/guide/en/logstash/current/installing-logstash.html
### -----

### --- Instalar o pacote Logstash.

sudo dnf install logstash -y

### --- Adicionar um certificado SSL baseado no endereço IP do servidor ELK na 
# linha abaixo da seção "[ v3_ca ]" em "/etc/pki/tls/openssl.cnf".

sudo sed -i '/^\[ v3_ca \]/a subjectAltName = IP: 192.168.121.200' /etc/pki/tls/openssl.cnf

### --- Gerar um certificado autoassinado válido por 365 dias.

cd /etc/pki/tls
sudo openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 365 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt

### --- Configurar os arquivos de entrada, saída e filtro do Logstash.

# - Input/entrada: Criar o arquivo "/etc/logstash/conf.d/input.conf" e inserir 
# as linhas abaixo. Isso é necessário para que o Logstash “aprenda” como 
# processar 'beats' provenientes de clientes. Certifique-se de que o caminho 
# para o certificado e a chave correspondam aos caminhos corretos, conforme 
# descrito na etapa anterior.

sudo bash -c 'cat > /etc/logstash/conf.d/input.conf << EOF
input {
  beats {
    port => 5044
    #ssl => true #Deprecated
    ssl_enabled => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
EOF'

# - Output/saída: Criar o arquivo "/etc/logstash/conf.d/output.conf" e inserir as linhas abaixo.

sudo bash -c 'cat > /etc/logstash/conf.d/output.conf << EOF
output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    sniffing => true
    manage_template => false
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
    #document_type => "%{[@metadata][type]}" #Deprecated
  }
}
EOF'

# - Filter/filtro: Criar o arquivo "/etc/logstash/conf.d/filter.conf". Registrará as 
# mensagens do "syslog" para simplificar.

sudo bash -c 'cat > /etc/logstash/conf.d/filter.conf << EOF
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGLINE}" }
  }

    date {
      match => [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
EOF'

### --- Habilitar e inicar o Logstash.

sudo systemctl daemon-reload
sudo systemctl enable logstash
sudo systemctl start logstash

### --- Testar a configuração do Logstash com comando abaixo. Direcionar a saída 
# para um arquivo. A saída deverá conter "Configuration OK".

sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t > /elk/remote_file_output/test_output_config_logstash.txt

### --- Configurar o firewall para permitir que o Logstash obtenha os logs dos 
# clientes [porta TCP 5044].

sudo firewall-cmd --add-port=5044/tcp
sudo firewall-cmd --add-port=5044/tcp --permanent
sudo firewall-cmd --reload
