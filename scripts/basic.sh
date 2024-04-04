#!/bin/bash

### --- Criar usuário 'elk' caso não exista.

if ! id -u elk >/dev/null 2>&1; then
  adduser elk
fi

### --- Mudar senha dos usuários.

usermod -aG wheel elk
echo 'elk:elk123' | chpasswd
echo 'vagrant:zaq1' | chpasswd
echo 'root:1qaz' | chpasswd

### --- Criar um par de chaves SSH.

ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa_vg-kvm-elk -C 'key Server Rocky Linux 9 - Elastic Stack' -N ""

### --- Atualizar repositório e instalar alguns pacotes.

sudo dnf update -y
sudo dnf install epel-release bind-utils net-tools -y
sudo dnf makecache
sudo dnf install nano wget nginx htop -y

### --- Modificar o motd.

sudo mv /etc/motd /etc/motd.ORIG
sudo cp /elk/configs/motd_elk /etc/motd_elk

### --- Inserir linhas no final do arquivo '/etc/profile' para config do '/etc/motd'.
# As cores básicas para "(tput setaf 'x')" são as numeradas abaixo:
# 1-vermelho; 2-verde; 3-amarelo; 4-azul; 5-magenta; 6-ciano; 7-branco

echo '' >> /etc/profile
echo '## start motd - config to motd' >> /etc/profile
echo 'export TERM=xterm-256color' >> /etc/profile
echo '(tput setaf 6)' >> /etc/profile
echo 'cat /etc/motd_elk' >> /etc/profile
echo '(tput setaf 6)' >> /etc/profile
echo 'echo ''' >> /etc/profile
echo 'echo '🅾🅿🅴🆁🅰🆃🅸🅽🅶 🆂🆈🆂🆃🅴🅼 :'' '`grep -oP "^PRETTY_NAME=\"\K[^\"]+" /etc/os-release`' >> /etc/profile
echo 'echo '🅷🅾🆂🆃🅽🅰🅼🅴 :'' '`hostname -s`' >> /etc/profile
echo 'echo '🅳🅰🆃🅴 :'' '`date`' >> /etc/profile
echo 'echo '🆄🅿🆃🅸🅼🅴 :'' '`uptime -p`' >> /etc/profile
echo 'echo '🅿🆄🅱🅻🅸🅲 🅸🅿 :'' '`dig +short myip.opendns.com @resolver1.opendns.com`' >> /etc/profile
echo 'echo '🅷🅾🅼🅴 :'' 'https://www.elastic.co/pt/elastic-stack/' >> /etc/profile
echo 'echo '🅳🅾🅲🆂 :'' 'https://www.elastic.co/guide/index.html' >> /etc/profile
echo 'echo ''' >> /etc/profile
echo '(tput setaf 7)' >> /etc/profile
echo '## end motd' >> /etc/profile
