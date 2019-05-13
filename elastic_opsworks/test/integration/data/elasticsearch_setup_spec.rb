describe yaml('/etc/elasticsearch/elasticsearch.yml') do
  its(%w(node.master)) { should eq(false) }
  its(%w(node.data)) { should eq(true) }
  its(%w(node.ingest)) { should eq(false) }
end
