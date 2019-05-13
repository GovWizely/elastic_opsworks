#
# Cookbook:: elastic_opsworks
# Recipe:: elasticsearch_setup
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'elastic_opsworks::default'
include_recipe 'java::default'

auto_create_indices = []
elasticsearch_plugins = node['elastic_opsworks']['elasticsearch']['plugins'].to_a

if node['elastic_opsworks']['xpack']['enabled']
  auto_create_indices += node['elastic_opsworks']['xpack']['indices']
  auto_create_indices += node['elastic_opsworks']['kibana']['indices']
end

unless auto_create_indices.empty?
  node.default['elastic_opsworks']['elasticsearch']['action.auto_create_index'] = auto_create_indices.join(',')
end

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  version node['elastic_opsworks']['elasticsearch']['version']
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
  'action.auto_create_index' => node['elastic_opsworks']['elasticsearch']['action.auto_create_index'],
  'bootstrap.memory_lock' => node['elastic_opsworks']['elasticsearch']['bootstrap.memory_lock'],
  'cluster.name' => node['elastic_opsworks']['elasticsearch']['cluster.name'],
  'cluster.routing.allocation.awareness.attributes' => instance['availability_zone'],
  'discovery.zen.hosts_provider' => 'ec2',
  'discovery.zen.minimum_master_nodes' => node['elastic_opsworks']['elasticsearch']['zen.minimum_master_nodes'],
  'network.host' => node['elastic_opsworks']['elasticsearch']['network.host']
}.merge role_configuration

merged_configuration = initial_configuration.merge node['elastic_opsworks']['elasticsearch']['custom_configuration']

elasticsearch_configure 'elasticsearch' do
  allocated_memory node['elastic_opsworks']['elasticsearch']['allocated_memory']
  configuration merged_configuration
end

%w(/etc/systemd /etc/systemd/system /etc/systemd/system/elasticsearch.service.d).each do |path|
  directory path do
    owner 'root'
    group 'root'
    only_if { ::File.exist?('/usr/lib/systemd') }
  end
end

cookbook_file '/etc/systemd/system/elasticsearch.service.d/elasticsearch.conf' do
  source 'systemd_elasticsearch.conf'
  owner 'root'
  group 'root'
  only_if { ::File.exist?('/usr/lib/systemd') }
end

bash 'set_elasticsearch_keystore_creds' do
  aws_access_key = application_hash['environment']['aws_access_key']
  aws_secret_key = application_hash['environment']['aws_secret_key']
  code <<-EOF
    echo #{aws_access_key} | /usr/share/elasticsearch/bin/elasticsearch-keystore add --stdin discovery.ec2.access_key
    echo #{aws_secret_key} | /usr/share/elasticsearch/bin/elasticsearch-keystore add discovery.ec2.secret_key
  EOF
  not_if 'sudo /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep access_key'
end

file '/etc/elasticsearch/elasticsearch.keystore' do
  action :touch
  owner 'root'
  group 'elasticsearch'
end

elasticsearch_plugins.each do |plugin|
  elasticsearch_plugin '-b ' + plugin unless File.exist?("/usr/share/elasticsearch/plugins/#{plugin}")
end

elasticsearch_service 'elasticsearch' do
  action [:configure, :enable, :start]
end
