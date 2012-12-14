#
# Cookbook Name:: shibboleth-idp
# Recipe:: default
#
# Copyright 2012 Nathan Mische
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Use encrypted data bag, if available

begin
  shibboleth_idp_data_bag = Chef::EncryptedDataBagItem.load("shibboleth","idp")[node.chef_environment]
  keystore_password = shibboleth_idp_data_bag['keystore_password']
rescue
  Chef::Log.info("No shibboleth-idp encrypted data bag found")
ensure
  keystore_password ||= node['shibboleth-idp']['keystore_password']
end

# Install trusted certs

include_recipe "shibboleth-idp::trustedcerts"

# Download installer

remote_file_name = "shibboleth-identityprovider-#{node['shibboleth-idp']['version']}-bin.zip"

remote_file "#{Chef::Config['file_cache_path']}/#{remote_file_name}" do
  source "http://shibboleth.net/downloads/identity-provider/#{node['shibboleth-idp']['version']}/#{remote_file_name}"
  action :create_if_missing
  mode "0744"
  owner "root"
  group "root"
end

# Install Shibboleth, see https://wiki.shibboleth.net/confluence/display/SHIB2/IdPInstall

execute "extract_shibboleth_idp_installer" do
  command "jar -xf shibboleth-identityprovider-#{node['shibboleth-idp']['version']}-bin.zip"
  cwd Chef::Config['file_cache_path']
  creates "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}"
  not_if { File.exists?("/opt/shibboleth-idp/war") }
end

# Template installer properties file as well as web.xml

template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/installer/resources/install.properties" do
  source "install.properties.erb"
  mode "0400"
  owner "root"
  group "root"
  not_if { File.exists?("/opt/shibboleth-idp/war") }
end

template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/main/webapp/WEB-INF/web.xml" do
  source "web.xml.erb"
  cookbook node['shibboleth-idp']['template_cookbook']
  mode "0644"
  owner "root"
  group "root"
  not_if { File.exists?("/opt/shibboleth-idp/war") }
end

# Customize the webapp

%w{ error-404.jsp error.jsp login-error.jsp login.css login.jsp }.each do |file|
  template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/main/webapp/#{file}" do
    source "#{file}.erb"
    cookbook node['shibboleth-idp']['template_cookbook']
    mode "0644"
    owner "root"
    group "root"
    not_if { File.exists?("/opt/shibboleth-idp/war") }
  end
end

# Run the installer 
# TODO: Figure you how to re-run when one of the above templates change

execute "run_shibboleth_idp_installer" do
  command <<-COMMAND    
    chmod u+x install.sh
    ./install.sh
    chown -R #{node['shibboleth-idp']['owner']}:#{node['shibboleth-idp']['group']} #{node['shibboleth-idp']['idp_home']}
  COMMAND
  cwd "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}"
  not_if { File.exists?("/opt/shibboleth-idp/war") }
  notifies :restart, "service[tomcat]", :delayed
end

# Configure Tomcat, see https://wiki.shibboleth.net/confluence/display/SHIB2/IdPApacheTomcatPrepare

execute "copy_shibboleth_idp_endorsed" do
  command "cp -r #{node['shibboleth-idp']['idp_home']}/lib/endorsed #{node['tomcat']['home']}/endorsed" 
  creates "#{node['tomcat']['home']}/endorsed"
  notifies :restart, "service[tomcat]", :delayed
end

remote_file "#{node['tomcat']['home']}/lib/tomcat6-dta-ssl-1.0.0.jar" do
  source node['shibboleth-idp']['tomcat6_dta_ssl_download_url']
  action :create_if_missing
  mode "0744"
  owner node['shibboleth-idp']['owner']
  group node['shibboleth-idp']['group']
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node['tomcat']['config_dir']}/Catalina/localhost/idp.xml" do
  source "idp.xml.erb"
  cookbook node['shibboleth-idp']['template_cookbook']
  mode "0644"
  owner node['shibboleth-idp']['owner']
  group node['shibboleth-idp']['group']
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node['tomcat']['config_dir']}/server.xml" do
  source "server.xml.erb"
  cookbook node['shibboleth-idp']['template_cookbook']
  mode "0644"
  owner node['shibboleth-idp']['owner']
  group node['shibboleth-idp']['group']
  variables(
    :keystoreFile => "#{node['shibboleth-idp']['idp_home']}/credentials/idp.jks",
    :keystorePass => keystore_password
  )
  notifies :restart, "service[tomcat]", :delayed
end
