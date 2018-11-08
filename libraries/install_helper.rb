# extracted from elasticsearch/libraries/provider_install.rb

module ElasticOpsworks
  module InstallHelper
    def install_repo_wrapper_action
      if node['platform_family'] == 'debian'
        apt_r = apt_repo_resource
        apt_r.run_action(:add)
        new_resource.updated_by_last_action(true) if apt_r.updated_by_last_action?
      else
        yr_r = yum_repo_resource
        yr_r.run_action(:create)
        new_resource.updated_by_last_action(true) if yr_r.updated_by_last_action?
      end

      if node['platform_family'] == 'rhel' && !new_resource.version.include?('-')
        # NB: yum repo packages are broken in Chef if you don't specify a release
        #     https://github.com/chef/chef/issues/4103
        new_resource.version = "#{new_resource.version}-1"
      end

      pkg_r = package new_resource.package_name do
        options new_resource.package_options
        version new_resource.version
        action :nothing
      end

      pkg_r.run_action(:install)
      new_resource.updated_by_last_action(true) if pkg_r.updated_by_last_action?
    end

    def remove_repo_wrapper_action
      if node['platform_family'] == 'debian'
        apt_r = apt_repo_resource
        apt_r.run_action(:remove)
        new_resource.updated_by_last_action(true) if apt_r.updated_by_last_action?
      else
        yr_r = yum_repo_resource
        yr_r.run_action(:delete)
        new_resource.updated_by_last_action(true) if yr_r.updated_by_last_action?
      end

      pkg_r = package 'elasticsearch' do
        options new_resource.package_options
        version new_resource.version
        action :nothing
      end
      pkg_r.run_action(:remove)
      new_resource.updated_by_last_action(true) if pkg_r.updated_by_last_action?
    end

    def install_package_wrapper_action
      download_url = determine_download_url(new_resource, node)
      filename = download_url.split('/').last
      checksum = determine_download_checksum(new_resource, node)
      package_options = new_resource.package_options

      unless checksum
        Chef::Log.warn("No checksum was provided for #{download_url}, this may download a new package on every chef run!")
      end

      remote_file_r = remote_file "#{Chef::Config[:file_cache_path]}/#{filename}" do
        source download_url
        checksum checksum
        mode '0644'
        action :nothing
      end
      remote_file_r.run_action(:create)
      new_resource.updated_by_last_action(true) if remote_file_r.updated_by_last_action?

      pkg_r = if node['platform_family'] == 'debian'
                dpkg_package "#{Chef::Config[:file_cache_path]}/#{filename}" do
                  options package_options
                  action :nothing
                end
              else
                package "#{Chef::Config[:file_cache_path]}/#{filename}" do
                  options package_options
                  action :nothing
                end
              end

      pkg_r.run_action(:install)
      new_resource.updated_by_last_action(true) if pkg_r.updated_by_last_action?
    end

    def remove_package_wrapper_action
      package_url = determine_download_url(new_resource, node)
      filename = package_url.split('/').last

      pkg_r = if node['platform_family'] == 'debian'
                dpkg_package "#{Chef::Config[:file_cache_path]}/#{filename}" do
                  action :nothing
                end
              else
                package "#{Chef::Config[:file_cache_path]}/#{filename}" do
                  action :nothing
                end
              end

      pkg_r.run_action(:remove)
      new_resource.updated_by_last_action(true) if pkg_r.updated_by_last_action?
    end

    def yum_repo_resource
      yum_repository 'elastic-6.x' do
        baseurl 'https://artifacts.elastic.co/packages/6.x/yum'
        gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
        action :nothing # :add, remove
      end
    end

    def apt_repo_resource
      apt_repository 'elastic-6.x' do
        uri 'https://artifacts.elastic.co/packages/6.x/apt'
        key 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
        components ['main']
        distribution 'stable'
        action :nothing # :create, :delete
      end
    end
  end
end
