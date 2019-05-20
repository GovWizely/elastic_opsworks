resource_name :elastic_user

property :username, String, name_property:true
property :current_password, String, required: true
property :new_password, String, required: true

action :update_password do
  http_request 'update password' do
    action :put
    url "http://#{node['hostname']}:9200/_xpack/security/user/#{username}/_password"
    headers(
      {
        'AUTHORIZATION' => "Basic #{Base64.encode64("#{username}:#{current_password}")}",
        'Content-Type' => 'application/data'
      }
    )
    message({ password: new_password }.to_json)
  end
end
