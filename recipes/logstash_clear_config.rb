#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_sync_config
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory '/etc/logstash/conf.d/' do
  recursive true
  action :create
end

directory '/etc/logstash/conf.d/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end