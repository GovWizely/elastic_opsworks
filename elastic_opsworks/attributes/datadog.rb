default['datadog']['hostname'] = node['fqdn'] || node['name']

default['datadog']['tags'] = {
    'env' => 'production',
    'stack' => 'elastic'
}
