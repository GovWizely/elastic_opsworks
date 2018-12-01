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

# execute 'start logstash' do
#   command 'sudo initctl start logstash'
# end

service 'logstash' do
  supports restart: true, status: true
  action [:enable, :start]
end
