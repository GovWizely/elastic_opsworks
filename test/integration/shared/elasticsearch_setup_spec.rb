describe yaml('/etc/elasticsearch/elasticsearch.yml') do
  its(%w(bootstrap.memory_lock)) { should eq(true) }

  its(%w(cluster.name)) { should eq('test-cluster') }

  its(%w(discovery.seed_providers)) { should eq('ec2') }
  its(%w(discovery.ec2.groups)) { should eq('es-sg') }

  its(%w(network.host)) { should eq('_ec2_') }
end
