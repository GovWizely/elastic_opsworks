#
# Cookbook:: elastic_opsworks
# Recipe:: change_built_in_user_passwords
#
# Copyright:: 2017, The Authors, All Rights Reserved.

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash

%w(kibana logstash_system beats_system apm_system remote_monitoring_user).each do |username|
  elastic_user username do
    action :change_password
    elastic_password application_hash['environment']['elastic_password']
    new_password application_hash['environment']["#{username}_password"]
  end
end
