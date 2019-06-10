#
# Cookbook:: elastic_opsworks
# Recipe:: create_logstash_internal_user
#
# Copyright:: 2019, The Authors, All Rights Reserved.

hostname = node['elastic_opsworks']['elasticsearch']['user_management_node'] || Chef::Config[:node_name]
create_role_url = "http://#{hostname}:9200/_xpack/security/role/logstash_writer"
create_role_body = {
  cluster: ['manage_index_templates', 'monitor', 'manage_ilm'],
  indices: [
    {
      names: ['logstash-*'],
      privileges: ['write', 'delete', 'create_index', 'manage', 'manage_ilm']
    }
  ]
}

application_hash = search(:aws_opsworks_app, 'shortname:elasticsearch').first.to_hash
elastic_password = application_hash['environment']['elastic_password']

http_request create_role_url do
  action :post
  url create_role_url
  message create_role_body.to_json
  headers('AUTHORIZATION' => "Basic #{ Base64.encode64("elastic:#{elastic_password}")}",
          'Content-Type' => 'application/json')
  sensitive true
end

create_user_url = "http://#{hostname}:9200/_xpack/security/user/logstash_internal"
create_user_body = {
  password: application_hash['environment']['logstash_internal_password'],
  roles: ['logstash_writer'],
  full_name: 'Internal Logstash User'
}

http_request create_user_url do
  action :post
  url create_user_url
  message create_user_body.to_json
  headers('AUTHORIZATION' => "Basic #{ Base64.encode64("elastic:#{elastic_password}")}",
          'Content-Type' => 'application/json')
  sensitive true
end
