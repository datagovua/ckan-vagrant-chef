# CKAN-Chef

A Vagrant deployment of CKAN using Chef as provisioner.

Creates an Ubuntu 12.04 VM running Postgres 9.4, Solr, Jetty, CKAN (master) and Datastore.

### For Development

Install [Vagrant](https://www.vagrantup.com/), clone this repository, then:

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

To make it easier to edit CKAN source and configuration files on the host machine, Vagrant synced_folders are available.

* `synced_folders/config` - by default, maps to `/etc/ckan/default` on the guest VM.
* `synced_folders/src` - by default, maps to `/usr/lib/ckan/default/src` on the guest VM.

These mappings are defined in the `Vagrantfile`.


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


