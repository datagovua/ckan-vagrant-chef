USER = node[:ckan][:user]
PROJECT_NAME = node[:ckan][:project_name]
SITE_URL = node[:ckan][:site_url]
ESCAPED_SITE_URL = SITE_URL.gsub('/','\\/')
SQL_PASSWORD = node[:ckan][:sql_password]
SQL_USER = "ckan_#{PROJECT_NAME}"
SQL_DB_NAME = "ckan_#{PROJECT_NAME}"
SOLR_URL = node[:ckan][:solr_url]
ESCAPED_SOLR_URL = SOLR_URL.gsub('/','\\/')
REPOSITORY_URL = node[:repository][:url]
COMMIT = node[:repository][:commit]

HOME = "/home/#{USER}"
ENV['VIRTUAL_ENV'] = "/usr/lib/ckan/#{PROJECT_NAME}"
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CONFIG_DIR = "/etc/ckan/#{PROJECT_NAME}"

# Create user
user USER do
  home HOME
  supports :manage_home => true
end

# Create virtualenv directory
directory ENV['VIRTUAL_ENV'] do
  owner USER
  group USER
  recursive true
  action :create
end

# Create python virtualenv
python_virtualenv ENV['VIRTUAL_ENV'] do
  interpreter "python2.7"
  owner USER
  group USER
  options "--no-site-packages"
  action :create
end

# Create source directory
directory SOURCE_DIR do
  owner USER
  group USER
  recursive true
  action :create
end

# Clone CKAN into source directory
git CKAN_DIR do
  user USER
  group USER
  repository REPOSITORY_URL
  reference COMMIT
  enable_submodules true
  action :sync
end

# Install CKAN Package
python_pip CKAN_DIR do
  user USER
  group USER
  virtualenv ENV['VIRTUAL_ENV']
  options "--exists-action=i -e"
  action :install
end

# Install CKAN's requirements
python_pip "#{CKAN_DIR}/requirements.txt" do
  user USER
  group USER
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Create Postgres User and Database
postgresql_user SQL_USER do
  superuser true
  createdb true
  login true
  password SQL_PASSWORD
end
postgresql_database SQL_DB_NAME do
  owner SQL_USER
  encoding "utf8"
end

# Create /etc/ckan directory
directory CONFIG_DIR do
  owner USER
  group USER
  recursive true
  action :create
end

# Create configuration file
execute "make paster's config file" do
  user USER
  cwd CONFIG_DIR
  command "paster make-config ckan development.ini --no-interactive"
  creates "#{CONFIG_DIR}/development.ini"
end

# Edit configuration file
# solr_url and ckan.site_id
execute "edit configuration file to setup ckan.site_url and ckan.site_id" do
  user USER
  cwd CONFIG_DIR
  command "sed -i -e 's/^ckan.site_id.*/ckan.site_id=#{PROJECT_NAME}/;s/.*ckan.site_url.*/ckan.site_url=#{ESCAPED_SITE_URL}/' development.ini"
end

# Configure database variables
execute "edit configuration file to setup database urls" do
  user USER
  cwd CONFIG_DIR
  command "sed -i -e 's/.*sqlalchemy.url.*/sqlalchemy.url=postgresql:\\/\\/#{SQL_USER}:#{SQL_PASSWORD}@localhost\\/#{SQL_DB_NAME}/' development.ini"
end

# Install and configure Solr
package "solr-jetty"
template "/etc/default/jetty" do
  variables({
    :java_home => node["java"]["java_home"]
  })
end
execute "setup solr's schema" do
  command "sudo ln -f -s #{CKAN_DIR}/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml"
  action :run
end
service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# Configure solr url
execute "edit configuration file to setup solr url" do
  user USER
  cwd CONFIG_DIR
  command "sed -i -e 's/.*solr_url.*/solr_url=#{ESCAPED_SOLR_URL}/' development.ini"
end

# Create database tables
execute "create database tables" do
  user USER
  cwd CKAN_DIR
  command "paster db init -c #{CONFIG_DIR}/development.ini"
end

# Link who.ini
link "#{CONFIG_DIR}/who.ini" do
  owner USER
  group USER
  to "#{SOURCE_DIR}/ckan/ckan/config/who.ini"
  action :create
end
