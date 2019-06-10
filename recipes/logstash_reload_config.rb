#
# Cookbook:: elastic_opsworks
# Recipe:: logstash_reload_config
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

execute 'reload logstash config' do
  command "kill -1 $(systemctl status logstash.service | grep PID | sed 's/[^0-9]*//g')"
end
