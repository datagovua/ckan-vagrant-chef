include_recipe "apache2::mod_wsgi"

#
# Mod RPAF
#

package "libapache2-mod-rpaf" do
  action :install
end

apache_module "rpaf" do
  enable true
  conf true
end


file "#{node[:ckan][:config_dir]}/production.ini" do
  content IO.read("#{node[:ckan][:config_dir]}/development.ini")
  action :create
end
