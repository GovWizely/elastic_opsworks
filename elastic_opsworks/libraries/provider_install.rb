class ElasticsearchCookbook::InstallProvider < Chef::Provider::LWRPBase
  def yum_repo_resource
    yum_repository 'elastic-7.x' do
      baseurl 'https://artifacts.elastic.co/packages/7.x/yum'
      gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
      action :nothing # :add, remove
    end
  end
end
