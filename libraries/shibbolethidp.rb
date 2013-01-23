#
# Cookbook Name:: shibboleth-idp
# Library:: shibbolethidp
#
# Copyright 2013, Nathan Mische
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

class Chef::Recipe::ShibbolethIdP 

    def self.get_keystore_password(node)

       begin
          if Chef::Config[:solo]
            begin 
              shibboleth_idp_data_bag = Chef::DataBagItem.load("shibboleth","idp")['local']
              keystore_password = shibboleth_idp_data_bag['keystore_password']
            rescue
              Chef::Log.info("No shibboleth-idp data bag found")
            end
          else
            begin 
              shibboleth_idp_data_bag = Chef::EncryptedDataBagItem.load("shibboleth","idp")[node.chef_environment]
              keystore_password = shibboleth_idp_data_bag['keystore_password']
            rescue
              Chef::Log.info("No shibboleth-idp encrypted data bag found")
            end
          end
        ensure    
          keystore_password ||= node['shibboleth-idp']['keystore_password']
        end

        keystore_password
        
    end

end