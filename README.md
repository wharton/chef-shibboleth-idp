# chef-shibboleth-idp [![Build Status](https://secure.travis-ci.org/wharton/chef-shibboleth-idp.png?branch=master)](http://travis-ci.org/wharton/chef-shibboleth-idp)

## Description

Installs/Configures Shibboleth Identity Provider (IdP).

## Requirements

### Platforms

* RedHat 6.3
* Ubuntu 12.04 (Precise)

### Cookbooks

Opscode Cookbooks (http://github.com/opscode-cookbooks/)

* java
* tomcat

## Attributes

More documentation here.

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

Copyright:: 2012

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.