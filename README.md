# chef-shibboleth-idp [![Build Status](https://secure.travis-ci.org/wharton/chef-shibboleth-idp.png?branch=master)](http://travis-ci.org/wharton/chef-shibboleth-idp)

## Description

Installs/Configures Shibboleth Identity Provider (IdP).

## Requirements

### Platforms

* CentOS 6
* RedHat 6
* Ubuntu 12.04 (Precise)

### Cookbooks

Required [Opscode Cookbooks](http://github.com/opscode-cookbooks/)

* [java](https://github.com/opscode-cookbooks/java)
* [tomcat](https://github.com/opscode-cookbooks/tomcat)

Required Third-Party Cookbooks

* [simple_iptables](https://github.com/dcrosta/cookbook-simple-iptables)

## Attributes

These attributes are under the `node['shibboleth-idp']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
container_auth | "basic" or "form" | String | form
custom_webapp_templates | Inject templates into IdP WAR | Array | nil
group | Group for Shibboleth IdP files | String | `node['tomcat']['group']`
host_name | Shibboleth IdP hostname | String | `node['fqdn']`
idp_home | Location to install Shibboleth IdP | String | /opt/shibboleth-idp
keystore_password | Keystore password (overridden by encrypted data bag attribute if exists) | String | changeit
owner | Owner for Shibboleth IdP files | String | `node['tomcat']['user']`
soap_port | Port number for Shibboleth IdP SOAP | Fixnum | 9443
status_allowed_ips | CIDRs with access to status information | Array | `%w{ 127.0.0.1/32 ::1/128 }`
template_cookbook | Cookbook to pull configuration files | String | shibboleth-idp
tomcat6_dta_ssl_download_url | URL to download Tomcat 6 DTA SSL jar | String | https://build.shibboleth.net/nexus/content/repositories/releases/edu/internet2/middleware/security/tomcat6/tomcat6-dta-ssl/1.0.0/tomcat6-dta-ssl-1.0.0.jar
version | Version of Shibboleth IdP for installation | String | 2.3.8

### iptables Attributes

These attributes are under the `node['shibboleth-idp']['ip_tables']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
in_interface | Define iptables interface | String | nil

### Logging Attributes

These attributes are under the `node['shibboleth-idp']['logging']` namespace. Valid values are: OFF, ERROR, WARN, INFO, DEBUG, TRACE, ALL.

Attribute | Description | Type | Default
----------|-------------|------|--------
edu.internet2.middleware.shibboleth | Shibboleth logging | String | INFO
edu.vt.middleware.ldap | LDAP logging | String | WARN
org.apache.catalina | Tomcat logging | String | ERROR
org.opensaml | SAML logging | String | WARN
org.springframework | Spring logging | String | OFF
PROTOCOL_MESSAGE | Protocol message logging | String | OFF

## Recipes

* `recipe[shibboleth-idp]` - Installs and enables Shibboleth IdP on Tomcat
* `recipe[shibboleth-idp::idp_configuration]` - Template IdP configuration via Chef
* `recipe[shibboleth-idp::idp_installation]` - Installs the Shibboleth IdP software
* `recipe[shibboleth-idp::iptables]` - Sets up port forwarding with iptables using simple_iptables cookbook
* `recipe[shibboleth-idp::tomcat_configuration]` - Template Tomcat configuration via Chef
* `recipe[shibboleth-idp::truststore]` - Adds additional trusted certificates to the JVM truststore

## Data Bags

* `shibboleth/idp` _optional_ encrypted data bag
  * `['keystore_password']` - IdP keystore password, overrides `node['shibboleth-idp']['keystore_password']`

## Usage

More documentation here.

## Contributing

Please use standard Github issues/pull requests.

## License and Author
      
Author:: Nathan Mische (<nmische@wharton.upenn.edu>), Brian Flad (<bflad@wharton.upenn.edu>)

Copyright:: 2012-2013

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.