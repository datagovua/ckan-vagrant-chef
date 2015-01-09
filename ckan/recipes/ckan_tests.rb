# Run tests for ckan and ckanext (optional)

TEST_SQL_DB_NAME = "#{node[:ckan][:sql_db_name]}_test"
DATASTORE_SQL_USER = "datastore_#{node[:ckan][:project_name]}"
DATASTORE_SQL_DB_NAME = "datastore_#{node[:ckan][:project_name]}_test"
ENV['VIRTUAL_ENV'] = "/usr/lib/ckan/#{node[:ckan][:project_name]}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CONFIG_DIR = "/etc/ckan/#{node[:ckan][:project_name]}"


# Install dev dependencies
python_pip "#{CKAN_DIR}/dev-requirements.txt" do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Create test databases
postgresql_database "#{SQL_DB_NAME}" do
  owner node[:ckan][:sql_user]
  encoding "utf8"
end
postgresql_database "#{DATASTORE_SQL_DB_NAME}" do
  owner node[:ckan][:sql_user]
  encoding "utf8"
end
# Configure test urls
execute "edit test configuration file to setup database url" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "sed -i -e 's/.*sqlalchemy.url.*/sqlalchemy.url=postgresql:\\/\\/#{node[:ckan][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{SQL_DB_NAME}/' test-core.ini"
end
execute "edit test configuration file to setup write datastore database url" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "sed -i -e 's/.*ckan.datastore.write_url.*/ckan.datastore.write_url=postgresql:\\/\\/#{node[:ckan][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{DATASTORE_SQL_DB_NAME}/' test-core.ini"
end
execute "edit test configuration file to setup read datastore database url" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "sed -i -e 's/.*ckan.datastore.read_url.*/ckan.datastore.read_url=postgresql:\\/\\/#{DATASTORE_SQL_USER}:#{node[:ckan][:sql_password]}@localhost\\/#{DATASTORE_SQL_DB_NAME}/' test-core.ini"
end

# Set permissions on test database tables
execute "set permissions on test database tables" do
  cwd CKAN_DIR
  command "paster --plugin=ckan datastore set-permissions -c test-core.ini | sudo -u postgres psql"
end

# Run the tests!
execute "run tests" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "nosetests --ckan --reset-db --with-pylons=test-core.ini --nologcapture ckan ckanext"
end
