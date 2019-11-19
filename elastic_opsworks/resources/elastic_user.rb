resource_name :elastic_user

property :username, String, name_property:true
property :elastic_password, String, required: true
property :new_password, String, required: true

action :change_password do
  hostname = node['elastic_opsworks']['elasticsearch']['user_management_node'] || Chef::Config[:node_name]
  change_password_url = "http://#{hostname}:9200/_security/user/#{username}/_password"
  body = { password: new_password }

  http_request change_password_url do
    action :post
    url change_password_url
    message body.to_json
    headers('AUTHORIZATION' => "Basic #{ Base64.encode64("elastic:#{elastic_password}")}",
            'Content-Type' => 'application/json')
    sensitive true
  end
end
