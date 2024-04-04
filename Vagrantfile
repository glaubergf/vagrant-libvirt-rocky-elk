# https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html

servers=[
	{
  :vm_hostname => "vg-kvm-elk",
	:vm_network => "br-db45a3ae7f61",
  :vm_ip => "192.168.121.200",
  :vm_mode => "virbr6",
  :vm_type => "bridge",
	:vm_box => "rockylinux/9",
  :vm_machine_virtual_size => 20,
  :vm_cpus => 4,
	:vm_mem => 4096,
  }
]

Vagrant.configure("2") do |config|

  servers.each do |srv|

    config.vm.define srv[:vm_hostname] do |node|

      node.vm.box = srv[:vm_box]
      node.vm.hostname = srv[:vm_hostname]
      node.vm.network "public_network", libvirt__always_destroy: false,
      # libvirt__always_destroy - Allow domains that use but did not create a network to 
      # destroy it when the domain is destroyed (default: true). Set to false to only allow 
      # the domain that created the network to destroy it.
        ip: srv[:vm_ip],
        dev: srv[:vm_network],
        mode: srv[:vm_mode],
        type: srv[:vm_type]

      node.vm.provider :libvirt do |kvm|
        kvm.machine_virtual_size = srv[:vm_machine_virtual_size]
        kvm.cpus = srv[:vm_cpus]
        kvm.memory = srv[:vm_mem]
        kvm.keymap = "pt-br"
        kvm.host = "localhost"
        kvm.uri = "qemu:///system"
      end

      node.vm.synced_folder ".", "/elk", disabled: false,
        create: true,
        type: "nfs",
        nfs_version: 4, 
        nfs_udp: false,
        mount_options: ['fsc','tcp','actimeo=2']
          # vers=3 -> especifica a versão 3 do protocolo NFS a ser usada
          # rw -> permissão de leitura e escrita
          # tcp -> especifica que a montagem NFS use o protocolo TCP
          # fsc -> fará com que o NFS use o FS-Cache
          # actimeo=2 -> tempo absoluto durante o qual as entradas de arquivo e diretório são mantidas no cache de atributos de arquivo após uma atualização

      config.vm.box_check_update = false

      config.ssh.insert_key = true
    
      #config.ssh.private_key_path = "~/.ssh/id_rsa"

      config.vm.post_up_message = "Bem-vindo ao Elastic Stack!"
    end
  end

  config.vm.provision "shell", path: "scripts/basic.sh"
  config.vm.provision "shell", path: "scripts/check_and_resize_disk_growpart.sh"
  config.vm.provision "shell", path: "scripts/install_elasticsearch.sh"
  config.vm.provision "shell", path: "scripts/install_kibana.sh"
  config.vm.provision "shell", path: "scripts/install_logstash.sh"
end
