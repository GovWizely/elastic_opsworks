#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_restart
#
# Copyright:: 2018, The Authors, All Rights Reserved.

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

execute 'sync_config' do
  environment ({
    "AWS_ACCESS_KEY_ID" => "#{application_hash['environment']['aws_access_key']}",
    "AWS_SECRET_ACCESS_KEY" => "#{application_hash['environment']['aws_secret_key']}"
  })
  command 'aws s3 sync s3://handle-logs-config logstash_config'
  action :run
end
