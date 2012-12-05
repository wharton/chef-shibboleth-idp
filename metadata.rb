name              "shibboleth-idp"
maintainer        "The Wharton School - The University of Pennsylvania"
maintainer_email  "chef-admins@wharton.upenn.edu"
license           "Apache 2.0"
description       "Installs/Configures Shibboleth Identity Provider"
version           "0.3.0"
recipe            "shibboleth-idp", "Installs and enables Shibboleth IdP on Tomcat."
recipe            "shibboleth-idp::idp_configuration", "Template IdP configuration via Chef."
recipe            "shibboleth-idp::idp_installation", "Installs the Shibboleth IdP software."
recipe            "shibboleth-idp::iptables", "Sets up port forwarding with iptables using simple_iptables cookbook."
recipe            "shibboleth-idp::tomcat_configuration", "Template Tomcat configuration via Chef."
recipe            "shibboleth-idp::truststore", "Adds additional trusted certificates in the JVM truststore."

%w{ tomcat java simple_iptables }.each do |d|
  depends d
end

%w{ ubuntu redhat }.each do |os|
  supports os
end
