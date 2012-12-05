#
# Cookbook Name:: shibboleth-idp
# Recipe:: truststore
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

# Import trusted certs from data bag if it exists
begin
  trusted_certs = data_bag("trusted_certs")
rescue
  Chef::Log.info("No trusted_certs data bag found.")
end

trusted_certs ||= []
trusted_certs.each do |certalias|

  cert = data_bag_item("trusted_certs", certalias)

  # Template the cert
  template "#{node['java']['java_home']}/jre/lib/security/trusted-#{certalias}.pem" do
    mode "0644"
    owner "root"
    group "root"
    source "pem.erb"
    variables(
      :certificate => cert["certificate"]
    )
  end

  # Import the cert
  execute "import_trusted-#{certalias}" do
    command "#{node['java']['java_home']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias #{certalias} -file trusted-#{certalias}.pem -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['java']['java_home']}/jre/lib/security"
    not_if "#{node['java']['java_home']}/jre/bin/keytool -list -alias #{certalias} -keystore #{node['java']['java_home']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[tomcat]", :delayed
  end

end