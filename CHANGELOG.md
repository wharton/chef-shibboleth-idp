## v0.5.3 ##

* Fixed server.xml template source cookbook

## v0.5.2 ##

* Added IdP Java Keystore password from encrypted data bag if available during IdP installation

## v0.5.0 ##

* Breaking into mutlipe recipes
* Changing templating method for tomcat server.xml

## v0.4.0 ##

* Added encrypted data bag support for keystore_password
* Extracted keystoreFile and keystorePass from server.xml template

## v0.3.0 ##

* Added Status AllowedIPs handling in web.xml template

## v0.2.0 ##

* Moved IdP configuration into its own recipe (`idp_configuration`) and removed attribute `['shibboleth-idp']['externally_manage_idp_config']`

## v0.1.8 ##

* Added `['shibboleth-idp']['externally_manage_idp_config']` attribute for not using Chef to template IdP config files

## v0.1.7 ##

* Make iptables in-interface configurable.

## v0.1.6

* Prevent Shibboleth IdP installer from running every Chef run

## v0.1.5

* Removed erroneous creates for remote_file in default recipe

## v0.1.4

* Ensure Shibboleth IdP remote_file is cached

## v0.1.3

* Can't use node["tomcat"] on bootstrap so let's guess tomcat user per platform like tomcat cookbook does

## v0.1.2

* Use tomcat cookbook attributes to correctly set user/group for shibboleth-idp

## v0.1.1

* Ensured trusted_certs data bag creation is optional

## v0.1.0

* Initial release.
