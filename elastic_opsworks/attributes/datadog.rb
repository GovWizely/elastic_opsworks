default['datadog']['hostname'] = node['fqdn'] || node['name']

default['datadog']['tags'] = {
    'env' => 'production',
    'stack' => 'elastic'
}
default['datadog']['elasticsearch']['instances'] = [
    {
        url: 'http://localhost:9200',
        tags: %w(layer:elasticsearch)
    }
]
