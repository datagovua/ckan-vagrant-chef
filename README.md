# CKAN-Chef

A Vagrant deployment of CKAN using Chef as provisioner.

Creates an Ubuntu 12.04 VM running Postgres 9.4, Solr, Jetty, CKAN (master) and Datastore.

## Installation

Install [Vagrant](https://www.vagrantup.com/), clone this repository, then:

`$ vagrant up`

### For Development

Login to the Vagrant VM:

`$ vagrant ssh`

Start the development server in the Vagrant VM:

```
$ cd /usr/lib/ckan/default/src/ckan
$ . ../../bin/activate
$ paster serve /etc/ckan/default/development.ini
```

View CKAN in your browser at `http://localhost:5000`.


### For Production


## Recipes

* `recipe[ckan::default]` collects together the recipes below.
* `recipe[ckan::ckan_base]` sets up everything needed for a CKAN instance ready for development.
* `recipe[ckan::ckan_datastore]` sets up the Datastore extension.
* `recipe[ckan::ckan_production]` sets up an Apache/Nginx server for serving CKAN in production.
* `recipe[ckan::ckan_tests]` runs ckan and ckanext tests.

## Attributes

CKAN configuration properties and installation locations can be tweaked in the attributes file: `/ckan/attributes/default.rb`.

Based on Victor Baptista's [chef-ckan](https://github.com/vitorbaptista/chef-ckan).


