#
# Cookbook:: elastic_opsworks
# Recipe:: elasticsearch_setup
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'java::default'

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  version node['elasticsearch']['version']
  download_url node['elasticsearch']['download_url']
  download_checksum node['elasticsearch']['download_checksum']
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

instance = search(:aws_opsworks_instance, 'self:true').first
valid_roles = %w(master data ingest)

role_configuration = {} if instance['role'] == %w(elasticsearch)

role_configuration ||= valid_roles.inject({}) do |hash, valid_role|
  hash["node.#{valid_role}"] = instance['role'].include? valid_role
  hash
end

Chef::Log.info "roles: #{role_configuration}"

initial_configuration = {
  'action.auto_create_index' => node['elasticsearch']['action.auto_create_index'],
  'bootstrap.memory_lock' => node['elasticsearch']['bootstrap.memory_lock'],
  'cluster.name' => node['elasticsearch']['cluster.name'],
  'cloud' => {
    'aws' => {
      'access_key' => application_hash['environment']['aws_access_key_id'],
      'secret_key' => application_hash['environment']['aws_secret_access_key'],
      'region' => application_hash['environment']['aws_region'],
    }
  },
  'discovery' => {
    'ec2' => {
      'groups' => application_hash['environment']['aws_security_groups']
    },
    'zen.hosts_provider' => 'ec2',
    'zen.minimum_master_nodes' => node['elasticsearch']['zen.minimum_master_nodes']
  },
  'network.host' => '_ec2:privateDns_'
}.merge role_configuration

merged_configuration = initial_configuration.merge node['elasticsearch']['custom_configuration']

elasticsearch_configure 'elasticsearch' do
  allocated_memory node['elasticsearch']['allocated_memory']
  configuration merged_configuration
end

elasticsearch_plugin 'discovery-ec2'
elasticsearch_plugin 'repository-s3'

elasticsearch_service 'elasticsearch' do
  action [:configure, :enable, :start]
end
