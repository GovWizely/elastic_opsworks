#
# Cookbook:: elastic_opsworks
# Recipe:: elasticsearch_setup
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'elastic_opsworks::default'
include_recipe 'java::default'

elasticsearch_plugins = node['elastic_opsworks']['elasticsearch']['plugins'].to_a

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
  'cloud.node.auto_attributes' => true,
  'cluster.routing.allocation.awareness.attributes' => 'aws_availability_zone',
  'discovery.seed_providers' => 'ec2',
  'network.host' => node['elastic_opsworks']['elasticsearch']['network.host'],
  'xpack.monitoring.collection.enabled' => true,
  'xpack.security.enabled' => true,
  'xpack.security.transport.ssl.enabled' => true,
  'xpack.security.transport.ssl.verification_mode' => 'certificate',
  'xpack.security.transport.ssl.keystore.path' => '/etc/elasticsearch/certs/elastic-certificates.p12',
  'xpack.security.transport.ssl.truststore.path' => '/etc/elasticsearch/certs/elastic-certificates.p12'
}.merge role_configuration

merged_configuration = initial_configuration.merge node['elastic_opsworks']['elasticsearch']['custom_configuration']

elasticsearch_configure 'elasticsearch' do
  cookbook_jvm_options 'elastic_opsworks'
  cookbook_log4j2_properties 'elastic_opsworks'
  jvm_options []
  allocated_memory node['elastic_opsworks']['elasticsearch']['allocated_memory']
  configuration merged_configuration
end

bootstrap_password = application_hash['environment']['bootstrap_password']
execute 'elasticsearch-keystore add bootstrap.password' do
  command "echo '#{bootstrap_password}' | bin/elasticsearch-keystore add bootstrap.password -f --stdin"
  cwd '/usr/share/elasticsearch'
  user 'root'
  group 'elasticsearch'
  not_if { bootstrap_password.nil? }
end

%w(access_key secret_key).each do |key_name|
  key_file_name = "#{Chef::Config['file_cache_path']}/#{key_name}"
  file key_file_name do
    content application_hash['environment']["aws_#{key_name}"]
    sensitive true
  end

  execute "elasticsearch-keystore add discovery.ec2.#{key_name}" do
    command "cat #{key_file_name} | bin/elasticsearch-keystore add discovery.ec2.#{key_name} -f --stdin"
    cwd '/usr/share/elasticsearch'
    user 'root'
    group 'elasticsearch'
  end

  execute "rm #{key_file_name}"
end

elasticsearch_plugins.each do |plugin|
  execute "bin/elasticsearch-plugin install -b #{plugin}" do
    cwd '/usr/share/elasticsearch'
    user 'root'
    group 'elasticsearch'
    not_if { ::File.exist?("/usr/share/elasticsearch/plugins/#{plugin}") }
  end
end

directory '/etc/systemd/system/elasticsearch.service.d' do
  owner 'root'
  group 'root'
  mode '0775'
end

cookbook_file '/etc/systemd/system/elasticsearch.service.d/override.conf' do
  source 'override.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

directory '/etc/elasticsearch/certs' do
  owner 'root'
  group 'elasticsearch'
  mode '0775'
end

cookbook_file '/etc/elasticsearch/certs/elastic-certificates.p12' do
  source 'elastic-certificates.p12'
  owner 'elasticsearch'
  group 'elasticsearch'
  mode '0660'
end

execute 'systemctl daemon-reload' do
  environment 'PATH' => '/usr/bin:/bin'
end

service 'elasticsearch' do
  action [:enable, :start]
end
