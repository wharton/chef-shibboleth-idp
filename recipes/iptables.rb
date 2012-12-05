#
# Cookbook Name:: shibboleth-idp
# Recipe:: iptables
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

# Forward 80 and 443

in_interface = node['shibboleth-idp']['ip_tables']['in_interface'] ? "--in-interface #{node['shibboleth-idp']['ip_tables']['in_interface']} " : ""

simple_iptables_rule "TOMCAT_HTTP_REDIRECTS" do
  table "nat"
  direction "PREROUTING"
  rule [ "#{in_interface}--protocol tcp --dport 80 --jump REDIRECT --to-port 8080",
         "#{in_interface}--protocol tcp --dport 443 --jump REDIRECT --to-port 8443" ]
  jump false
end
