#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_setup
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

include_recipe 'elastic_opsworks::elasticsearch_setup'

elastic_install 'logstash' do
  version node['elastic_opsworks']['elasticsearch']['version']
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash
logstash_keystore_password = application_hash['environment']['logstash_keystore_password'] || 'logstash'
logstash_keystore_env_hash = {
  'LOGSTASH_KEYSTORE_PASS' => logstash_keystore_password
}

file '/etc/sysconfig/logstash' do
  content "LOGSTASH_KEYSTORE_PASS=#{logstash_keystore_password}"
  owner 'root'
  group 'root'
  mode '0600'
end

logstash_keystore_path = '/etc/logstash/logstash.keystore'

execute 'logstash system-install' do
  command '/usr/share/logstash/bin/system-install /etc/logstash/startup.options systemd'
  not_if { ::File.exist?(logstash_keystore_path) }
end

execute 'logstash-keystore create' do
  command 'bin/logstash-keystore --path.settings /etc/logstash create'
  cwd '/usr/share/logstash'
  environment logstash_keystore_env_hash
  not_if { ::File.exist?(logstash_keystore_path) }
end

secure_settings = {
  'access_key_id' => application_hash['environment']['aws_access_key'],
  'secret_access_key' => application_hash['environment']['aws_secret_key'],
  'logstash_internal.password' => application_hash['environment']['logstash_internal_password']
}

secure_settings.each do |key, value|
  key_file_name = "#{Chef::Config['file_cache_path']}/#{key}"
  file key_file_name do
    content value
    sensitive true
  end

  execute 'logstash-keystore remove' do
    command "bin/logstash-keystore --path.settings /etc/logstash remove #{key}"
    cwd '/usr/share/logstash'
    environment logstash_keystore_env_hash
    only_if "bin/logstash-keystore --path.settings /etc/logstash list | grep #{key}"
  end

  execute 'logstash-keystore add' do
    command "cat #{key_file_name} | bin/logstash-keystore --path.settings /etc/logstash add #{key}"
    cwd '/usr/share/logstash'
    environment logstash_keystore_env_hash
  end

  execute "rm #{key_file_name}"
end

instance = search(:aws_opsworks_instance, 'self:true').first

initial_configuration = {
  'node.name' => Chef::Config[:node_name],
  'path.data' => '/var/lib/logstash',
  'path.logs' => '/var/log/logstash',
  'xpack.monitoring.enabled' => true,
  'xpack.monitoring.elasticsearch.hosts' => ["http://#{instance['private_ip']}:9200"],
  'xpack.monitoring.elasticsearch.username' => node['elastic_opsworks']['logstash']['elasticsearch.username'],
  'xpack.monitoring.elasticsearch.password' => application_hash['environment']['logstash_system_password']
}

merged_configuration = initial_configuration.merge node['elastic_opsworks']['logstash']['custom_configuration']

template '/etc/logstash/logstash.yml' do
  source 'yml.erb'
  variables(config: merged_configuration)
end

template '/etc/logrotate.d/logstash' do
  source 'logstash_logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables('log_path' => '/var/log/logstash/*.log')
end

directory '/etc/logstash/templates/' do
  owner 'logstash'
  group 'logstash'
  mode '0755'
  action :create
end

service 'logstash' do
  supports restart: true, status: true
  action [:enable, :start]
end
