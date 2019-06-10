#
# Cookbook:: elastic_opsworks
# Recipe:: kibana_restart
#
# Copyright:: 2019, The Authors, All Rights Reserved.

service 'kibana' do
  action [:restart]
end
