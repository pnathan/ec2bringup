# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box =  "ubuntu/trusty64"
  config.vm.network :forwarded_port, guest: 80, host: 3000

  config.ssh.forward_agent = true

  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "chef/cookbooks"
    chef.nodes_path = "chef/nodes"
    chef.roles_path = "chef/roles"

#    chef.add_recipe "apt"
#    chef.add_recipe "docker"
    chef.add_recipe "cluster"
  end
end
