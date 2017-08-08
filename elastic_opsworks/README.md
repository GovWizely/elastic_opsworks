# elastic stack in OpsWorks Cookbook

- Install and configure elastic stack in OpsWorks

# Requirements

- AWS OpsWorks with Chef 12
- AWS credentials with IAM policy to access [S3 and EC2](elastic_aws_cloud_plugin_policy.json)
- AWS security group for inter cluster communication on port `9200` and `9300`
- AWS security group for client access to the `data` nodes on port `9200`

# elasticsearch App

## Environment Variables

- `aws_access_key_id`

    Configure the `cloud.aws.access_key` in `elasticsearch.yml`

- `aws_secret_access_key`

    Configure the `cloud.aws.secret_key` in `elasticsearch.yml`

- `aws_region`

    Configure the `cloud.aws.region` in `elasticsearch.yml`

- `aws_security_groups` 
    
    Configure the `discovery.ec2.groups` in `elasticsearch.yml`

# Usage

- Add `elasticsearch` App with the environment variables mentioned above

- Add `elasticsearch` layer if you want a node with default roles

- Add `master` layer if you want a dedicated master nodes
    
    - Add `elastic_opsworks::elasticsearch_setup` in the `Setup` lifecycle event
    - Set inter cluster security group

- Add `3` instances to the `master` layer

- Add `data` layer if you want a dedicated data nodes

    - Add `elastic_opsworks::elasticsearch_setup` in the `Setup` lifecycle event
    - Set inter cluster security group
    - Setup client access security group

- Add at least `2` instances to the `data` layer

# Attributes

- `node['elasticsearch']['cluster.name']` - Configure elasticsearch cluster name (REQUIRED)
- `node['elasticsearch']['allocated_memory']` - Override the default allocated memory
- `node['elasticsearch']['custom_configuration']` - Add additional key value pairs configuration in `elasticsearch.yml`
- `node['elasticsearch']['zen.minimum_master_nodes']` - Override the default 2 minimum master nodes
