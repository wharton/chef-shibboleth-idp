#
# Cookbook Name:: shibboleth-idp
# Recipe:: idp_configuration
#
# Copyright 2012 Brian Flad
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

# Template all the Shibboleth IdP configuration files
%w{ attribute-filter attribute-resolver handler internal logging relying-party service }.each do |config|
  template "#{node['shibboleth-idp']['idp_home']}/conf/#{config}.xml" do
    source "#{config}.xml.erb"
    cookbook node['shibboleth-idp']['template_cookbook']
    mode "0644"
    owner node['shibboleth-idp']['owner']
    group node['shibboleth-idp']['group']
    notifies :restart, "service[tomcat]", :delayed
  end
end

template "#{node['shibboleth-idp']['idp_home']}/conf/login.config" do
  source "login.config.erb"
  cookbook node['shibboleth-idp']['template_cookbook']
  mode "0644"
  owner node['shibboleth-idp']['owner']
  group node['shibboleth-idp']['group']
  notifies :restart, "service[tomcat]", :delayed
end
