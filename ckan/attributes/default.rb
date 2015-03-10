# for development deploys using Vagrant, `[:ckan][:user]` must be 'vagrant' to ensure
# synced_folders have correct permissions
default[:ckan][:user] = "ckan"
default[:ckan][:project_name] = "default"
default[:ckan][:site_url] = "http://data-gov-ua.org"
default[:ckan][:solr_url] = "http://127.0.0.1:8983/solr"
default[:ckan][:sql_password] = "pass"
default[:ckan][:sql_user] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:sql_db_name] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:virtual_env_dir] = "/usr/lib/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:config_dir] = "/etc/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:file_storage_dir] = "/var/lib/ckan/#{default[:ckan][:project_name]}"

default[:ckan][:datastore][:sql_user] = "datastore_#{default[:ckan][:project_name]}"  # readonly db user
default[:ckan][:datastore][:sql_db_name] = "datastore_#{default[:ckan][:project_name]}"

default[:datapusher][:virtual_env_dir] = "/usr/lib/datapusher/#{default[:ckan][:project_name]}"
default[:datapusher][:repository][:url] = "https://github.com/ckan/datapusher.git"
default[:datapusher][:repository][:commit] = "stable"

# The CKAN version to install.
default[:repository][:url] = "https://github.com/ckan/ckan.git"
default[:repository][:commit] = "release-v2.3"

# Apache config for production
default[:apache][:server_name] = "data-gov-ua.org"
default[:apache][:server_alias] = "www.data-gov-ua.org"
