#
# Cookbook:: elastic_opsworks
# Recipe:: elasticsearch_restart
#
# Copyright:: 2017, The Authors, All Rights Reserved.

elasticsearch_service 'elasticsearch' do
  action [:restart]
end
