describe yaml('/etc/elasticsearch/elasticsearch.yml') do
  its(%w(action.auto_create_index)) { should eq '.security,.monitoring*,.watches,.triggered_watches,.watcher-history*,.kibana' }
  its(%w(node.master)) { should eq false }
  its(%w(node.data)) { should eq false }
  its(%w(node.ingest)) { should eq false }
end

describe yaml('/etc/kibana/kibana.yml') do
  its(%w(elasticsearch.url)) { should eq 'http://172.31.38.211:9200' }
  its(%w(elasticsearch.username)) { should eq 'kibana' }
  its(%w(elasticsearch.password)) { should eq 'barfoo' }
  its(%w(pid.file)) { should eq '/var/run/kibana/kibana.pid' }
  its(%w(server.host)) { should eq '172.31.38.211' }
end

describe file('/etc/logrotate.d/kibana') do
  its('content') { should contain('/var/log/kibana/kibana.stdout /var/log/kibana/kibana.stderr') }
end
