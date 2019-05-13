#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_sync_templates
#
# Copyright:: 2018, The Authors, All Rights Reserved.

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash
logstash_template_bucket = "#{application_hash['environment']['logstash_template_bucket']}"
aws_access_key = "#{application_hash['environment']['aws_access_key']}"
aws_secret_key = "#{application_hash['environment']['aws_secret_key']}"

execute 'sync_templates' do
  command "aws s3 sync s3://#{logstash_template_bucket} /etc/logstash/templates/"
  environment ({
    'AWS_ACCESS_KEY_ID' => "#{aws_access_key}",
    'AWS_SECRET_ACCESS_KEY' => "#{aws_secret_key}"
  })
end
