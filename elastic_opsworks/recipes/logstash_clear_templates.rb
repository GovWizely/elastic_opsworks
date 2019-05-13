#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_clear_template
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory '/etc/logstash/templates/' do
  recursive true
  action :delete
end

directory '/etc/logstash/templates/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end