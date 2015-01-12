# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.berkshelf.enabled = true

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network "forwarded_port", guest: 8983, host: 8983
  config.vm.network "forwarded_port", guest: 5000, host: 5000

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end

  config.vm.synced_folder "synced_folders/src", "/usr/lib/ckan/default/src",
                          id: "ckan_src",
                          owner: "vagrant",
                          group: "vagrant",
                          mount_options: ["dmode=775","fmode=664"]
  config.vm.synced_folder "synced_folders/config", "/etc/ckan/default",
                          id: "ckan_config",
                          owner: "vagrant",
                          group: "vagrant",
                          mount_options: ["dmode=775","fmode=664"]
  config.vm.synced_folder "synced_folders/file_storage", "/var/lib/ckan/default",
                          id: "ckan_file_storage",
                          owner: "vagrant",
                          group: "www-data",
                          mount_options: ["dmode=775","fmode=664"]

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      "recipe[ckan::default]",
    ]
  end
end
