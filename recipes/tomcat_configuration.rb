#
# Cookbook Name:: shibboleth-idp
# Recipe:: idp_configuration
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

# Configure Tomcat, see https://wiki.shibboleth.net/confluence/display/SHIB2/IdPApacheTomcatPrepare

# Use encrypted data bag, if available

begin
  shibboleth_idp_data_bag = Chef::EncryptedDataBagItem.load("shibboleth","idp")[node.chef_environment]
  keystore_password = shibboleth_idp_data_bag['keystore_password']
rescue
  Chef::Log.info("No shibboleth-idp encrypted data bag found")
ensure
  keystore_password ||= node['shibboleth-idp']['keystore_password']
end

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

=begin
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
=end

tomcat_sever_xml_template = resources(:template => "#{node["tomcat"]["config_dir"]}/server.xml")
tomcat_sever_xml_template.cookbook "shibboleth-idp"
tomcat_sever_xml_template.variables(
  :keystoreFile => "#{node['shibboleth-idp']['idp_home']}/credentials/idp.jks",
  :keystorePass => keystore_password
)

