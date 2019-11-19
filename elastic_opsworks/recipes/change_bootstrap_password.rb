#
# Cookbook:: elastic_opsworks
# Recipe:: change_bootstrap_password
#
# Copyright:: 2019, The Authors, All Rights Reserved.

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

elastic_user 'elastic' do
  action :change_password
  elastic_password application_hash['environment']['bootstrap_password']
  new_password application_hash['environment']['elastic_password']
end
