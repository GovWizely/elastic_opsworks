describe yaml('/etc/elasticsearch/elasticsearch.yml') do
  its(%w(action.auto_create_index)) { should be true }
  its(%w(node.master)) { should eq false }
  its(%w(node.data)) { should eq false }
  its(%w(node.ingest)) { should eq false }
end

describe yaml('/etc/kibana/kibana.yml') do
  its(%w(elasticsearch.hosts)) { should eq ['http://172.31.38.211:9200'] }
  its(%w(pid.file)) { should eq '/var/run/kibana/kibana.pid' }
  its(%w(server.host)) { should eq '172.31.38.211' }
end
