#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_restart
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory '/home/ec2-user/.aws' do
  owner 'ec2-user'
  group 'ec2-user'
  mode '0755'
  action :create
end

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

file '/home/ec2-user/.aws/credentials' do
  not_if { ::File.exist?('/home/ec2-user/.aws/config') }
  content "[default]
aws_access_key_id = #{application_hash['environment']['aws_access_key']}
aws_secret_access_key = #{application_hash['environment']['aws_secret_key']}
"
end

aws_s3_file '/home/ec2-user/logstash_config/handle-logs.conf' do
  bucket 'handle-logs-config'
end