maintainer        "The Wharton School - The University of Pennsylvania"
maintainer_email  "chef-admins@wharton.upenn.edu"
license           "Apache 2.0"
description       "Installs/Configures Shibboleth Identity Provider"
version           "0.1.0"
recipe            "shibboleth-idp", "Installs and enables Shibboleth IdP on Tomcat."

%w{ tomcat java }.each do |d|
  depends d
end

%w{ ubuntu redhat }.each do |os|
  supports os
end
