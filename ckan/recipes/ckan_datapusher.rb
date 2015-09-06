# Installs and configures the datastore extension
# Must be run after ckan::ckan_base recipe.

ENV['VIRTUAL_ENV'] = node[:datapusher][:virtual_env_dir]
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
DATAPUSHER_DIR = "#{SOURCE_DIR}/datapusher"

execute "install apt packages" do
  command "sudo apt-get -y install python-dev python-virtualenv build-essential libxslt1-dev libxml2-dev git"
end

directory ENV['VIRTUAL_ENV'] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

execute "chown virtual env" do
  command "chown -R #{node[:ckan][:user]}:#{node[:ckan][:user]} #{ENV['VIRTUAL_ENV']}"
end

python_virtualenv ENV['VIRTUAL_ENV'] do
  interpreter "python2.7"
  owner node[:ckan][:user]
  group node[:ckan][:user]
  options "--no-site-packages"
  action :create
end

directory DATAPUSHER_DIR do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

git DATAPUSHER_DIR do
  user node[:ckan][:user]
  group node[:ckan][:user]
  repository node[:datapusher][:repository][:url]
  reference node[:datapusher][:repository][:commit]
  enable_submodules true
  action :sync
end

#python_pip "#{ENV['VIRTUAL_ENV']}" do
#  user node[:ckan][:user]
#  group node[:ckan][:user]
#  virtualenv ENV['VIRTUAL_ENV']
#  options "--exists-action=i -e"
#  action :install
#end

# Install DataPusher's requirements
python_pip "#{DATAPUSHER_DIR}/requirements.txt" do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Install DataPusher
python_pip DATAPUSHER_DIR do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "--exists-action=i -e"
  action :install
end



# Add datastore to ckan.plugins
execute "add datastore to ckan.plugins in configuration" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  # first ensure any ' datastore' is removed from line, then add it again.
  command "sed -i -e '/^ckan.plugins.*/ s/ datapusher//g;/^ckan.plugins.*/ s/$/ datapusher/' development.ini"
end

template "#{node[:ckan][:config_dir]}/datapusher.wsgi" do
    source "datapusher.wsgi.erb"
    variables({
        :datapusher_env => "#{ENV['VIRTUAL_ENV']}",
        :config_dir => "#{node[:ckan][:config_dir]}"
    })
end

template "/etc/apache2/sites-available/datapusher.conf" do
    source "datapusher_apache_conf.erb"
    variables({
        :source_dir => "#{DATAPUSHER_DIR}",
        :config_dir => "#{node[:ckan][:config_dir]}"
    })
end

execute "copy datapusher settings" do
  command "cp #{DATAPUSHER_DIR}/deployment/datapusher_settings.py #{node[:ckan][:config_dir]}"
end

execute "enable apache site" do
  command "sudo a2ensite datapusher.conf"
end

