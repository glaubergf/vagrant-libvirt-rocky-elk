---
 Projeto: vagrant-rockylinux-elastic-stack
 Descrição: O Vagrantfile provisiona um servidor Rocky Linux 9 (RHEL) para ser instalado o Elastick Stack (Elasticsearch/kibana/Logstash/Beats). Os scripts automatiza a instalação e configuração dos produtos do ELK Stack e de alguns pacotes e configurção do sistema.
Autor: Glauber GF [mcnd2]
Data: 2024-03-11
---

# Elastic Stack no Rocky Linux 9 com Vagrant (libvirt)

![Image](https://github.com/glaubergf/vagrant-libvirt-rocky-elk/blob/main/pictures/server_rocky_elk.png)

O **[Elastic Stack](https://www.elastic.co/pt/elastic-stack/)** (_também conhecido como ELK Stack_) é composto pelos seguintes produtos: _Elasticsearch_, _Kibana_, _Beats_ e _Logstash_. Com isso, podemos obter dados de maneira confiável e segura de qualquer fonte, em qualquer formato, depois, fazer buscas, análises e visualizações.

Nesse projeto, será provisionado uma VM (_Máquina Virtual_) do **[Rocky Linux 9](https://rockylinux.org/)** com o **[Vagrant](https://www.vagrantup.com/)** usando o provider **[libvirt](https://libvirt.org/)**. No momento que a VM estiver sendo provisionada, será executado via shell script automatizando a instalação dos produtos do _Elastic Stack_ mencionado acima.

## O Processo

Além do **_Vagrantfile_** que tem todos os parâmetros para provisionar a VM,
tem **_6 script_** para automatizar as terefas que vai desde redimencionar o disco, como instalar alguns pacotes e os produtos em si. 

Assim, no diretório do projeto, já com o vagrant instalado basta executar o seguinte comando:

- validar se não há errors na sintaxe do Vagrantfile.

```
vagrant validate
```

- iniciar e provisionar o ambienet vagrant.

```
vagrant up
```

- desligar o ambienet vagrant.

```
vagrant halt 
```

- destruir o ambienet vagrant.

```
vagrant destroy -f
```

Abaixo, segue alguns aspectos sobre o projeto.

### Vagrantfile
___

* Provisionar a VM com IP estático.
* Criar o Disco maior que o default (10 G) da box do Rocky Linux.
* Setar quantidade de vCPU e de Memória.
* Sincronizar um diretório específico com o NFS.

### Scripts
___

Há 6 scripts de modo a automatizar as tarefas para redimencionar o disco, além de executar e configurar os produtos do Elastic Stack.

#### No servidor
___

#### script_basic

Automatizar tarefas de administração do sistema Linux de forma programática.

* Criação do usuário 'elk': Se o usuário 'elk' não existir, o script cria esse usuário.

* Modificação de senhas de usuários: O script altera as senhas dos usuários 'elk', 'vagrant' e 'root'.

* Criação de chave hash: Gerar um par de chaves SSH, que é uma forma segura de autenticação para servidores e sistemas remotos.

* Atualização de repositórios e instalação de pacotes: O script atualiza os repositórios do sistema, instala o repositório EPEL, ferramentas de rede (bind-utils), e pacotes como nano, wget, nginx e htop.

* Modificação do Message of the Day (MOTD): O script renomeia o arquivo /etc/motd original para /etc/motd.ORIG e copia um novo arquivo de configuração do MOTD (/elk/config/motd_elk) para /etc/motd_elk.

* Configuração do MOTD no arquivo /etc/profile: O script adiciona linhas ao final do arquivo /etc/profile para configurar o MOTD, incluindo a exibição de informações do sistema como nome do sistema operacional, nome do host, data, tempo de atividade, endereço IP externo e links para recursos da Elastic.

#### script_check_and_resize_disk_growpart.sh

Útil para expandir o espaço disponível na partição raiz da VM do sistema Rocky Linux, permitindo uma melhor utilização do espaço em disco alocado para a VM.

* Verificar se algum disco tem tamanho menor que 20G: Utiliza o comando **lsblk -b** para listar todos os dispositivos de bloco e filtra os discos com tamanho menor que 20G usando **awk**.

* Identificar a partição raiz "/": Se um disco menor que 20G for encontrado, o script identifica a partição raiz "/" usando **lsblk -f** e filtra a saída para encontrar a partição raiz.

* Redimensionar a partição raiz "/": Utiliza o comando **growpart** para redimensionar a partição raiz para ocupar todo o espaço disponível no disco.

* Estender o sistema de arquivos XFS: Após redimensionar a partição, o script usa **xfs_growfs** para estender o sistema de arquivos XFS para ocupar todo o espaço disponível na partição.

* Dependencia do pacote **cloud-utils-growpart** para ser instalado para executar o comando _growpart_.

#### script_install_elasticsearch

Guia para a instalar e configurar o Elasticsearch em um servidor Rocky Linux 9, preparando o ambiente para uso em projetos de análise de dados e monitoramento.

* Atualizar o cache do repositório e instalar pacotes necessários como nano, wget, nginx, e htop.

* Ativar e iniciar o firewall, permitindo o tráfego HTTP e HTTPS.

* Baixar e instalar o Java, uma dependência para o Elastic Stack, a partir de um binário.

* Importar a chave GPG pública do Elasticsearch para o gerenciador de pacotes RPM.

* Configurar o repositório do Elasticsearch para a instalação do pacote Elasticsearch.

* Instalar o Elasticsearch, destacando a necessidade de anotar a senha gerada para o superusuário elastic.

* Iniciar e ativar o serviço Elasticsearch.

* Resetar a senha do usuário elastic e salvá-la em um arquivo.

* Editar o arquivo de configuração do Elasticsearch para restringir o acesso externo e permitir o tráfego na porta TCP 9200.

* Verificar se o Elasticsearch está respondendo a solicitações HTTP simples usando o comando curl.

#### script_install_kibana

Guia para instalar e configurar o Kibana, uma ferramenta de visualização de dados do Elastic Stack, em um sistema operacional Linux baseado em RPM.

* Instalar o Kibana via gerenciador de pacotes dnf.

* Modificar o arquivo de configuração do Kibana para definir o host do servidor Kibana para um IP específico, permitindo que o Kibana seja acessado a partir de qualquer IP.

* Carregar as configurações do sistema, habilitar o serviço Kibana para iniciar automaticamente na inicialização do sistema e iniciar o serviço Kibana.

* Utilizar o comando openssl para criar um usuário administrativo com a senha que será armazenado no arquivo '/etc/nginx/htpasswd.users'.

* Configurar o firewall para permitir o tráfego na porta 5601, necessária para acessar a interface web do Kibana.

* Criar um arquivo de configuração para o Nginx que redireciona o tráfego para o Kibana, utilizando o arquivo 'htpasswd.users' para autenticação básica.

* Verificar se a configuração do Nginx está correta.

* Habilitar o serviço Nginx para iniciar automaticamente na inicialização do sistema e reiniciar o serviço para aplicar as configurações.

#### script_install_logstash

Parte essencial na configuração de um ambiente ELK (_Elasticsearch_, _Logstash_, _Kibana_), permitindo a coleta, processamento e visualização de dados de log de forma eficiente, centraliza os dados de log de várias fontes em um único local.

* Instalar o Lgstash via gerenciador de pacotes dnf.

* Adicionar um certificado SSL baseado no endereço IP do servidor ELK ao arquivo de configuração do OpenSSL (openssl.cnf), permitindo a comunicação segura entre o Logstash e os clientes.

* Criar um certificado autoassinado válido por 365 dias para o Logstash, utilizando o OpenSSL.

* Definir as configurações de entrada, saída e filtro do Logstash. A entrada é configurada para aceitar conexões seguras (beats) na porta 5044, a saída é configurada para enviar dados para o Elasticsearch e o filtro é configurado para processar mensagens do syslog.

* Carregar as configurações do Logstash, habilitar o serviço para iniciar na inicialização do sistema e iniciar o serviço Logstash.

* Executar um teste de configuração do Logstash para verificar se a configuração está correta.

* Permitir o tráfego na porta TCP 5044, necessária para a comunicação segura entre o Logstash e os clientes.


#### No cliente
___

#### script_install_metricbeat_client

Guia para instalar e configurar o Metricbeat em um cliente Debian, com o objetivo de coletar métricas do sistema e enviá-las para um servidor Elasticsearch. Principais etapas:

* Copiar o certificado SSL do servidor Rocky 9 para o cliente Debian 12, utilizando o comando scp.

* Importar a chave GPG pública do Elasticsearch para o gerenciador de pacotes apt na máquina cliente, permitindo a instalação segura de pacotes do Elastic.

* Configurar o repositório para o Metricbeat, adicionando-o à lista de fontes de pacotes do apt.

* Garantir que o pacote apt-transport-https esteja instalado, necessário para acessar repositórios via HTTPS.

* Atualizar os repositórios, instala o Metricbeat, habilita e inicia o serviço.

* Modificar o arquivo de configuração do Metricbeat para definir as informações de conexão com o Elasticsearch e o Kibana, incluindo detalhes como hosts, credenciais e, opcionalmente, o finger impresso do certificado SSL.

* Habilitar o módulo system do Metricbeat e configurar para coletar métricas específicas, como logs do syslog e logs de autorização.

* Executar o comando setup do Metricbeat para carregar os painéis do Kibana e reiniciar o serviço para aplicar as configurações.

## Licença
 
**GNU General Public License** (_Licença Pública Geral GNU_), **GNU GPL** ou simplesmente **GPL**.
 
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
