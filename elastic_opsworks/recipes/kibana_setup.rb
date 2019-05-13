#
# Cookbook:: elastic_opsworks
# Recipe:: kibana_setup
#
# Copyright:: 2017, The Authors, All Rights Reserved.

node.default['elastic_opsworks']['elasticsearch']['plugins'] = node['elastic_opsworks']['elasticsearch']['plugins']
include_recipe 'elastic_opsworks::elasticsearch_setup'
include_recipe 'elastic_opsworks::logstash_setup'

elastic_install 'kibana' do
  version node['elastic_opsworks']['elasticsearch']['version']
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash
instance = search(:aws_opsworks_instance, 'self:true').first

directory '/var/run/kibana' do
  owner 'kibana'
  group 'kibana'
  mode '0755'
end

kibana_pid_file = '/var/run/kibana/kibana.pid'

initial_configuration = {
  'elasticsearch.url' => "http://#{instance['private_ip']}:9200",
  'pid.file' => kibana_pid_file,
  'server.host' => instance['private_ip']
}

merged_configuration = initial_configuration.merge node['elastic_opsworks']['kibana']['custom_configuration']

template '/etc/kibana/kibana.yml' do
  source 'kibana.yml.erb'
  variables(config: merged_configuration)
  not_if "grep '^elasticsearch.username' /etc/kibana/kibana.yml"
end

service 'kibana' do
  supports restart: true, status: true
  action [:enable, :start]
end

template '/etc/logrotate.d/kibana' do
  source 'kibana_logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    log_path: '/var/log/kibana/kibana.stdout /var/log/kibana/kibana.stderr',
    pid: kibana_pid_file,
    username: 'kibana'
  )
end
