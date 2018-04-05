#
# Cookbook:: elastic_opsworks
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'apt::default'
include_recipe 'datadog::dd-agent'
include_recipe 'datadog::dd-handler'
