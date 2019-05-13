resource_name :kibana_plugin

property :plugin_name, String, name_property:true

action :install do
  cmd = '/usr/share/kibana/bin/kibana-plugin'
  execute "#{cmd} install #{plugin_name}" do
    user 'kibana'
    group 'kibana'
    not_if "#{cmd} list | grep ^#{Regexp.escape(plugin_name)}", user: 'kibana', group: 'kibana'
  end
end
