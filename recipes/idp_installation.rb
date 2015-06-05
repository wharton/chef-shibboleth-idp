#
# Cookbook Name:: shibboleth-idp
# Recipe:: idp_installation
#
# Copyright 2012 Nathan Mische, Brian Flad
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

# Get the configured keystore password

keystore_password = ShibbolethIdP.get_keystore_password(node)

# Setup Checksum

shibboleth_zip_checksum = node['shibboleth-idp']['checksum']
if node['shibboleth-idp']['version'] == "2.3.8"
  shibboleth_zip_checksum ||= "332e5ec32a494ae44c895e2ba21af1ea5ea6665cb66339bef4db1e818cf02e56" #Checksum for version 2.3.8
end

# Download installer

remote_file_name = "shibboleth-identityprovider-#{node['shibboleth-idp']['version']}-bin.zip"

remote_file "#{Chef::Config['file_cache_path']}/#{remote_file_name}" do
  source "http://shibboleth.net/downloads/identity-provider/#{node['shibboleth-idp']['version']}/#{remote_file_name}"
  mode "0744"
  owner "root"
  group "root"
  if shibboleth_zip_checksum
    checksum shibboleth_zip_checksum
  else
    not_if { File.exists?("/opt/shibboleth-idp/war") }
  end
  notifies :run, 'execute[extract_shibboleth_idp_installer]', :immediately
end

# Install Shibboleth, see https://wiki.shibboleth.net/confluence/display/SHIB2/IdPInstall

execute "extract_shibboleth_idp_installer" do
  command "jar -xf shibboleth-identityprovider-#{node['shibboleth-idp']['version']}-bin.zip"
  cwd Chef::Config['file_cache_path']
  creates "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}"
  action :nothing
end

# Template installer properties 

template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/installer/resources/install.properties" do
  source "install.properties.erb"
  mode "0600"
  owner "root"
  group "root"
  variables(
    :keystore_password => keystore_password
  )
  notifies :run, 'execute[should_install_shibboleth]', :immediately
end

# Customize the webapp

template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/main/webapp/WEB-INF/web.xml" do
  source "web.xml.erb"
  cookbook node['shibboleth-idp']['template_cookbook']
  mode "0644"
  owner "root"
  group "root"
  notifies :run, 'execute[should_install_shibboleth]', :immediately
end

%w{ error-404.jsp error.jsp login-error.jsp login.css login.jsp }.each do |file|
  template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/main/webapp/#{file}" do
    source "#{file}.erb"
    cookbook node['shibboleth-idp']['template_cookbook']
    mode "0644"
    owner "root"
    group "root"
    notifies :run, 'execute[should_install_shibboleth]', :immediately
  end
end

# Inject custom files into the webapp

custom_files = node['shibboleth-idp']['custom_webapp_files']
custom_files ||= []

custom_files.each do |file|
  cookbook_file "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/main/webapp/#{file}" do
    source file
    cookbook node['shibboleth-idp']['template_cookbook']
    mode "0644"
    owner "root"
    group "root"
    notifies :run, 'execute[should_install_shibboleth]', :immediately
  end
end


# Inject custom templates into the webapp

custom_templates = node['shibboleth-idp']['custom_webapp_templates']
custom_templates ||= []

custom_templates.each do |file|
  template "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}/src/main/webapp/#{file}" do
    source "#{file}.erb"
    cookbook node['shibboleth-idp']['template_cookbook']
    mode "0644"
    owner "root"
    group "root"
    notifies :run, 'execute[should_install_shibboleth]', :immediately
  end
end

# Set flag to run installer

execute "should_install_shibboleth" do
  command "touch /tmp/should_install_shibboleth"
  action :nothing
end

# Run the installer 

execute "run_shibboleth_idp_installer" do
  command <<-COMMAND    
    rm -f /tmp/should_install_shibboleth
    chmod u+x install.sh
    ./install.sh
    chown -R #{node['shibboleth-idp']['owner']}:#{node['shibboleth-idp']['group']} #{node['shibboleth-idp']['idp_home']}
  COMMAND
  cwd "#{Chef::Config['file_cache_path']}/shibboleth-identityprovider-#{node['shibboleth-idp']['version']}"
  action :run
  only_if 'test -f /tmp/should_install_shibboleth'
  notifies :restart, "service[tomcat]", :delayed
end