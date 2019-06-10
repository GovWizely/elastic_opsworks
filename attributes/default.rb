default['elastic_opsworks']['elasticsearch']['action.auto_create_index'] = true
default['elastic_opsworks']['elasticsearch']['bootstrap.memory_lock'] = true
default['elastic_opsworks']['elasticsearch']['custom_configuration'] = {}
default['elastic_opsworks']['elasticsearch']['network.host'] = '_ec2_'
default['elastic_opsworks']['elasticsearch']['plugins'] = %w(discovery-ec2 repository-s3)
default['elastic_opsworks']['elasticsearch']['version'] = '7.1.1'

default['elastic_opsworks']['kibana']['elasticsearch.username'] = 'kibana'
default['elastic_opsworks']['kibana']['custom_configuration'] = {}
default['elastic_opsworks']['kibana']['indices'] = %w(.kibana)

default['elastic_opsworks']['logstash']['elasticsearch.username'] = 'logstash_system'
default['elastic_opsworks']['logstash']['custom_configuration'] = {}
