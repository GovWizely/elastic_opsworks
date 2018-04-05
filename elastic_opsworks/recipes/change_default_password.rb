#
# Cookbook:: elastic_opsworks
# Recipe:: change_default_password
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'datadog::dd-handler'

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

elastic_user 'elastic' do
  action :update_password
  current_password 'changeme'
  new_password application_hash['environment']['elastic_password']
end

elastic_user 'kibana' do
  action :update_password
  current_password 'changeme'
  new_password application_hash['environment']['kibana_password']
end

elastic_user 'logstash_system' do
  action :update_password
  current_password 'changeme'
  new_password application_hash['environment']['logstash_system_password']
end
