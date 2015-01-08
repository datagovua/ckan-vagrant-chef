# Installs and configures the datastore extension
# Must be run after ckan::default recipe.

USER = node[:ckan][:user]
PROJECT_NAME = node[:ckan][:project_name]
ENV['VIRTUAL_ENV'] = "/usr/lib/ckan/#{PROJECT_NAME}"
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SQL_USER = "ckan_#{PROJECT_NAME}"
SQL_PASSWORD = node[:ckan][:sql_password]
DATASTORE_SQL_USER = "datastore_#{PROJECT_NAME}"
DATASTORE_SQL_DB_NAME = "datastore_#{PROJECT_NAME}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CONFIG_DIR = "/etc/ckan/#{PROJECT_NAME}"

# Create readonly pg user and database
postgresql_user DATASTORE_SQL_USER do
  superuser false
  createdb false
  login true
  password SQL_PASSWORD
end
postgresql_database DATASTORE_SQL_DB_NAME do
  owner SQL_USER
  encoding "utf8"
end

# Configure database variables
execute "Set up datastore database write urls" do
  user USER
  cwd CONFIG_DIR
  command "sed -i -e 's/.*datastore.write_url.*/ckan.datastore.write_url=postgresql:\\/\\/#{SQL_USER}:#{SQL_PASSWORD}@localhost\\/#{DATASTORE_SQL_DB_NAME}/' development.ini"
end
execute "Set up datastore database read urls" do
  user USER
  cwd CONFIG_DIR
  command "sed -i -e 's/.*datastore.read_url.*/ckan.datastore.read_url=postgresql:\\/\\/#{DATASTORE_SQL_USER}:#{SQL_PASSWORD}@localhost\\/#{DATASTORE_SQL_DB_NAME}/' development.ini"
end
# Add datastore to ckan.plugins
execute "add datastore to ckan.plugins in configuration" do
  user USER
  cwd CONFIG_DIR
  # first ensure any ' datastore' is removed from line, then add it again.
  command "sed -i -e '/^ckan.plugins.*/ s/ datastore//g;/^ckan.plugins.*/ s/$/ datastore/' development.ini"
end

execute "set permissions" do
  cwd CKAN_DIR
  command "paster --plugin=ckan datastore set-permissions -c #{CONFIG_DIR}/development.ini | sudo -u postgres psql --set ON_ERROR_STOP=1"
end
