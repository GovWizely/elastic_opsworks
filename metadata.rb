name 'elastic_opsworks'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures elastic_opsworks'
long_description 'Installs/Configures elastic_opsworks'
version '0.1.0'
chef_version '>= 12.18.31' if respond_to?(:chef_version)

depends 'elasticsearch', '> 4.0'
depends 'java'
depends 'aws'
