# CKAN-Chef

A Vagrant deployment of CKAN using Chef as provisioner.

Creates an Ubuntu 12.04 VM running Postgres 9.4, Solr, Jetty, CKAN (master) and Datastore.

### For Development

Install VirtualBox, Vagrant and Berkshelf:

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Install Berkshelf by installing the [ChefDK](https://downloads.chef.io/chef-dk/)
4. Install the vagrant-berkshelf plugin with:

`$ vagrant plugin install vagrant-berkshelf`

Clone this repository, then:

`$ vagrant up`

Log in to the Vagrant VM:

`$ vagrant ssh`

Start the development server in the Vagrant VM:

```
$ cd /usr/lib/ckan/default/src/ckan
$ source ../../bin/activate
$ paster serve /etc/ckan/default/development.ini
```

View CKAN in your browser at `http://localhost:5000`.

#### Vagrant synced folders

To make it easier to edit CKAN source and configuration files from the host machine, Vagrant synced_folders are defined as follows by default.

* `synced_folders/config`: maps to `/etc/ckan/default` on the guest VM.
* `synced_folders/src`: maps to `/usr/lib/ckan/default/src` on the guest VM.
* `synced_folders/file_storage`: maps to `/var/lib/ckan/default` on the guest VM.

These mappings are defined in the `Vagrantfile`.

#### Vagrant commands

Some useful Vagrant commands:

`$ vagrant up` Create and configure the guest machine.

`$ vagrant ssh` Login to the guest machine.

`$ vagrant suspend` Suspend the current state of the guest machine.

`$ vagrant halt` Attempt a shutdown of the guest machine.

`$ vagrant provision` Re-provision the guest machine according to the Chef cookbook.

`$ vagrant reload` Restart the guest machine. Add the `--provision` flag to also re-provision.

`$ vagrant destroy` Stops the guest machine and removes all of its resources. This will destroy the CKAN database and any uncommitted changes to the source code in the guest machine.

See [Vagrant documentation](http://docs.vagrantup.com/v2/cli/index.html) for a full list of commands.

#### Troubleshooting

If you get errors using `$ vagrant up` after `$ vagrant destroy`, you may need to delete the `synced_folders/config` directory to ensure a new `development.ini` file is created.


### For Production

:::TODO:::


## Recipes

* `recipe[ckan::default]` collects together the recipes below.
* `recipe[ckan::ckan_base]` sets up everything needed for a CKAN instance ready for development.
* `recipe[ckan::ckan_datastore]` sets up the Datastore extension.
* `recipe[ckan::ckan_production]` sets up an Apache/Nginx server for serving CKAN in production.
* `recipe[ckan::ckan_tests]` runs ckan and ckanext tests.

## Attributes

CKAN configuration properties and installation locations can be tweaked in the attributes file: `/ckan/attributes/default.rb`.

Based on Victor Baptista's [chef-ckan](https://github.com/vitorbaptista/chef-ckan).


