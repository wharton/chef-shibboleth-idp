name              "shibboleth-idp"
maintainer        "The Wharton School - The University of Pennsylvania"
maintainer_email  "chef-admins@wharton.upenn.edu"
license           "Apache 2.0"
description       "Installs/Configures Shibboleth Identity Provider"
version           "0.1.5"
recipe            "shibboleth-idp", "Installs and enables Shibboleth IdP on Tomcat."
recipe            "shibboleth-idp::iptables", "Sets up iptables with port forwarding."
recipe            "shibboleth-idp::trustedcerts", "Installs Java trusted certificates."

%w{ tomcat java }.each do |d|
  depends d
end

%w{ ubuntu redhat }.each do |os|
  supports os
end
