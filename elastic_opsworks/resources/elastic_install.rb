resource_name :elastic_install

property :package_name, String, name_property:true
property :version, String, required:true
property :download_url, String, required: true
property :download_checksum, String, required: true
property :package_options, String

action :install do
  install_repo_wrapper_action
end

action :remove do

end

action_class do
  include ElasticOpsworks::InstallHelper
end
