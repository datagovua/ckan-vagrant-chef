# Run tests for ckan and ckanext (optional)

USER = node[:ckan][:user]
PROJECT_NAME = node[:ckan][:project_name]
SQL_PASSWORD = node[:ckan][:sql_password]
SQL_USER = "ckan_#{PROJECT_NAME}"
SQL_DB_NAME = "ckan_#{PROJECT_NAME}_test"
DATASTORE_SQL_USER = "datastore_#{PROJECT_NAME}"
DATASTORE_SQL_DB_NAME = "datastore_#{PROJECT_NAME}_test"
ENV['VIRTUAL_ENV'] = "/usr/lib/ckan/#{PROJECT_NAME}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CONFIG_DIR = "/etc/ckan/#{PROJECT_NAME}"


# Install dev dependencies
python_pip "#{CKAN_DIR}/dev-requirements.txt" do
  user USER
  group USER
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Create test databases
postgresql_database "#{SQL_DB_NAME}" do
  owner SQL_USER
  encoding "utf8"
end
postgresql_database "#{DATASTORE_SQL_DB_NAME}" do
  owner SQL_USER
  encoding "utf8"
end
# Configure test urls
execute "edit test configuration file to setup database url" do
  user USER
  cwd CKAN_DIR
  command "sed -i -e 's/.*sqlalchemy.url.*/sqlalchemy.url=postgresql:\\/\\/#{SQL_USER}:#{SQL_PASSWORD}@localhost\\/#{SQL_DB_NAME}/' test-core.ini"
end
execute "edit test configuration file to setup write datastore database url" do
  user USER
  cwd CKAN_DIR
  command "sed -i -e 's/.*ckan.datastore.write_url.*/ckan.datastore.write_url=postgresql:\\/\\/#{SQL_USER}:#{SQL_PASSWORD}@localhost\\/#{DATASTORE_SQL_DB_NAME}/' test-core.ini"
end
execute "edit test configuration file to setup read datastore database url" do
  user USER
  cwd CKAN_DIR
  command "sed -i -e 's/.*ckan.datastore.read_url.*/ckan.datastore.read_url=postgresql:\\/\\/#{DATASTORE_SQL_USER}:#{SQL_PASSWORD}@localhost\\/#{DATASTORE_SQL_DB_NAME}/' test-core.ini"
end

# Set permissions on test database tables
execute "set permissions on test database tables" do
  cwd CKAN_DIR
  command "paster --plugin=ckan datastore set-permissions -c test-core.ini | sudo -u postgres psql"
end

# Run the tests!
execute "run tests" do
  user USER
  cwd CKAN_DIR
  command "nosetests --ckan --reset-db --with-pylons=test-core.ini --nologcapture ckan ckanext"
end
