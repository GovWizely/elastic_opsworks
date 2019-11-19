#
# Cookbook:: elastic_opsworks
# Recipe:: kibana_setup
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'elastic_opsworks::elasticsearch_setup'

elastic_install 'kibana' do
  version node['elastic_opsworks']['elasticsearch']['version']
end

instance = search(:aws_opsworks_instance, 'self:true').first

directory '/var/run/kibana' do
  owner 'kibana'
  group 'kibana'
  mode '0755'
end

kibana_pid_file = '/var/run/kibana/kibana.pid'

initial_configuration = {
  'server.name' => Chef::Config[:node_name],
  'elasticsearch.hosts' => ["http://#{instance['private_ip']}:9200"],
  'pid.file' => kibana_pid_file,
  'server.host' => instance['private_ip']
}

merged_configuration = initial_configuration.merge node['elastic_opsworks']['kibana']['custom_configuration']

template '/etc/kibana/kibana.yml' do
  source 'yml.erb'
  variables(config: merged_configuration)
end

execute 'bin/kibana-keystore create' do
  cwd '/usr/share/kibana'
  user 'kibana'
  group 'kibana'
  not_if { ::File.exist?('/var/lib/kibana/kibana.keystore') }
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

kibana_credentials = {
  'elasticsearch.username' => node['elastic_opsworks']['kibana']['elasticsearch.username'],
  'elasticsearch.password' => application_hash['environment']['kibana_password']
}

kibana_credentials.each do |(key_name, key_value)|
  key_file_name = "#{Chef::Config['file_cache_path']}/kibana_#{key_name}"
  file "#{key_file_name}" do
    content key_value
    sensitive true
  end

  execute "kibana-keystore add #{key_name}" do
    command "cat #{key_file_name} | bin/kibana-keystore add #{key_name} -f --stdin"
    cwd '/usr/share/kibana'
    user 'kibana'
    group 'kibana'
  end

  execute "rm #{key_file_name}"
end

service 'kibana' do
  supports restart: true, status: true
  action [:enable, :start]
end
