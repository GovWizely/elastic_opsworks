default['elastic_opsworks']['elasticsearch']['action.auto_create_index'] = false
default['elastic_opsworks']['elasticsearch']['bootstrap.memory_lock'] = true
default['elastic_opsworks']['elasticsearch']['cluster.name'] = nil
default['elastic_opsworks']['elasticsearch']['custom_configuration'] = {}
default['elastic_opsworks']['elasticsearch']['network.host'] = '_ec2_'
default['elastic_opsworks']['elasticsearch']['plugins'] = %w(discovery-ec2 repository-s3)
default['elastic_opsworks']['elasticsearch']['version'] = '6.6'
default['elastic_opsworks']['elasticsearch']['zen.minimum_master_nodes'] = 2

default['elastic_opsworks']['kibana']['custom_configuration'] = {}
default['elastic_opsworks']['kibana']['indices'] = %w(.kibana)
default['elastic_opsworks']['kibana']['version'] = '6.5.4'

default['elastic_opsworks']['xpack']['enabled'] = true
default['elastic_opsworks']['xpack']['indices'] = %w(.security .monitoring* .watches .triggered_watches .watcher-history*)
