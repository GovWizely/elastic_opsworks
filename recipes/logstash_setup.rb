#
# Cookbook:: elastic_opsworks
# Recipe:: logstash
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

execute 'install public signing key' do
  command 'rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  action :run
end

file '/etc/yum.repos.d/logstash.repo' do
  content '[logstash-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1c
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

'
end

yum_package 'logstash'

service 'logstash' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, status: true
  action [:enable, :start]
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

file '/etc/logstash/aws_credentials.yml' do
  not_if { ::File.exist?('/etc/logstash/aws_credentials.yml') }
  content ":access_key_id:  #{application_hash['environment']['aws_access_key']}
:secret_access_key:  #{application_hash['environment']['aws_secret_key']}
"
end
