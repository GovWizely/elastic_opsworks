#
# Cookbook:: elastic_opsworks
# Recipe:: logstash
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

include_recipe 'elastic_opsworks::elasticsearch_setup'

elastic_install 'logstash' do
  version node['elastic_opsworks']['elasticsearch']['version']
end

execute 'logstash system-install' do
  command '/usr/share/logstash/bin/system-install /etc/logstash/startup.options sysv'
  user 'root'
end

execute 'chkconfig logstash' do
  command '/sbin/chkconfig logstash on'
  user 'root'
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

file '/etc/logstash/aws_credentials.yml' do
  not_if { ::File.exist?('/etc/logstash/aws_credentials.yml') }
  content ":access_key_id:  #{application_hash['environment']['aws_access_key']}
:secret_access_key:  #{application_hash['environment']['aws_secret_key']}
"
end

template '/etc/logrotate.d/logstash' do
  source 'logstash_logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    log_path: '/var/log/logstash.stdout /var/log/logstash.stderr',
    username: 'logstash'
  )
end

directory '/etc/logstash/templates/' do
  owner 'logstash'
  group 'logstash'
  mode '0755'
  action :create
end

service 'logstash' do
  supports restart: true, status: true
  action [:enable, :start]
end
