default[:ckan][:user] = "ckan"
default[:ckan][:project_name] = "default"
default[:ckan][:site_url] = "http://localhost:5000"
default[:ckan][:solr_url] = "http://127.0.0.1:8983/solr"
default[:ckan][:sql_password] = "pass"
default[:ckan][:sql_user] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:sql_db_name] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:virtual_env_dir] = "/usr/lib/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:config_dir] = "/etc/ckan/#{default[:ckan][:project_name]}"

default[:ckan][:datastore][:sql_user] = "datastore_#{default[:ckan][:project_name]}"  # readonly db user
default[:ckan][:datastore][:sql_db_name] = "datastore_#{default[:ckan][:project_name]}"

default[:repository][:url] = "https://github.com/ckan/ckan.git"
default[:repository][:commit] = "master"
