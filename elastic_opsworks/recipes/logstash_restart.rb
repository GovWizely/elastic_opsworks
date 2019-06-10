#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_restart
#
# Copyright:: 2018, The Authors, All Rights Reserved.

service 'logstash' do
  action [:restart]
end
