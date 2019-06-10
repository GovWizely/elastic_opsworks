#
# Cookbook:: elastic_opsworks
# Recipe:: seed_logstash_config_bucket
#
# Copyright:: 2019, The Authors, All Rights Reserved.
#

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

placeholder_conf_path = "#{Chef::Config['file_cache_path']}/98-placeholder.conf"

template placeholder_conf_path do
  source '98-placeholder.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables('input_bucket' => application_hash['environment']['logstash_input_bucket'])
end

logstash_config_bucket = application_hash['environment']['logstash_config_bucket']

execute "aws s3 cp #{placeholder_conf_path} s3://#{logstash_config_bucket}/" do
  environment('AWS_ACCESS_KEY_ID' => application_hash['environment']['aws_access_key'],
              'AWS_SECRET_ACCESS_KEY' => application_hash['environment']['aws_secret_key'])
  sensitive true
end

file placeholder_conf_path do
  action :delete
end
