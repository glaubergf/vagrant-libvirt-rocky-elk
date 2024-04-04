#!/bin/bash

### --- Instalar o pacte "cloud-utils-growpart".

sudo dnf install cloud-utils-growpart -y

### --- Verificar se algum disco tem tamanho menor que 20G usando 'lsblk'.
# O comando lsblk lista todos os dispositivos de bloco, incluindo discos e partições.
# O comando awk filtra a saída para encontrar a coluna 'size' e verifica se é menor que 20G.
# O comando grep procura por 'disk' na coluna 'type'.

disco_pequeno=$(lsblk -b | awk '$3<20G && $6=="disk" {print $1}')

if [ -n "$disco_pequeno" ]; then
    echo "Disco(s) pequeno(s) encontrado(s): $disco_pequeno"
    
    ### --- Identificar a partição raiz "/" usando 'lsblk -f'.
    # O comando lsblk -f lista todos os dispositivos de bloco com informações adicionais, como o ponto de montagem.
    # O comando awk filtra a saída para encontrar a partição raiz "/".
    
    particao_raiz=$(lsblk -f | awk '$6=="/" {print $1}')
    
    if [ -n "$particao_raiz" ]; then
        echo "Partição raiz encontrada: $particao_raiz"
        
        ### --- Redimensionar a partição raiz "/" no sistema de arquivos 'XFS'.
        # O comando growpart redimensiona a partição para ocupar todo o espaço disponível no disco.
        # O variável "$numero_particao_raiz" indica que essa partição deve ser redimensionada para ocupar todo o espaço disponível.

        numero_particao_raiz=$(echo "$particao_raiz" | awk '{print substr($0, length)}')
        
        echo "Redimensionando a partição raiz..."
        sudo growpart /dev/$disco_pequeno $numero_particao_raiz
        
        ### --- Estender o sistema de arquivos XFS para ocupar todo o espaço disponível.
        # O comando xfs_growfs redimensiona o sistema de arquivos para ocupar todo o espaço disponível na partição.
        
        echo "Estendendo o sistema de arquivos XFS..."
        sudo xfs_growfs /
        
        echo "Sistema de arquivos XFS estendido com sucesso."
    else
        echo "Partição raiz não encontrada."
    fi
else
    echo "Nenhum disco pequeno encontrado."
fi
