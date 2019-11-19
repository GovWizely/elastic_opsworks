describe yaml('/etc/elasticsearch/elasticsearch.yml') do
  its(%w(action.auto_create_index)) { should be true }
  its(%w(node.master)) { should eq nil }
  its(%w(node.data)) { should eq nil }
  its(%w(node.ingest)) { should eq nil }
end
