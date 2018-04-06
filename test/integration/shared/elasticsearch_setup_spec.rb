describe yaml('/etc/elasticsearch/elasticsearch.yml') do
  its(%w(bootstrap.memory_lock)) { should eq(true) }

  its(%w(cloud aws access_key)) { should eq('MY_AWS_ACCESS_KEY_ID') }
  its(%w(cloud aws secret_key)) { should eq('MY_AWS_SECRET_ACCESS_KEY') }
  its(%w(cloud aws region)) { should eq('us-west-1') }

  its(%w(cluster.name)) { should eq('test-cluster') }

  its(%w(discovery zen.hosts_provider)) { should eq('ec2') }
  its(%w(discovery zen.minimum_master_nodes)) { should eq(2) }
  its(%w(discovery ec2 groups)) { should eq('es-sg') }

  its(%w(network.host)) { should eq('_ec2:privateDns_') }
end

describe yaml('/etc/dd-agent/conf.d/elastic.yaml') do
  its(['instances', 0, 'url']) { should eq 'http://172.31.38.211:9200' }
  its(['instances', 0, 'tags', 0]) { should eq 'layer:elasticsearch' }
end
