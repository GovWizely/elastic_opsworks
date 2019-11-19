# elastic stack in OpsWorks Cookbook

- Install and configure elastic stack in OpsWorks

# Requirements

- AWS OpsWorks with Chef 12
- AWS credentials with IAM policy to access [S3 and EC2](elastic_aws_cloud_plugin_policy.json)
- AWS security group for inter cluster communication on port `9200` and `9300`
- AWS security group for client access to the `data` nodes on port `9200`
- AWS security group for kibana nodes on port `5601`

# Stack settings

- Default operating system: Amazon Linux 2

# elasticsearch App

## Environment Variables

- `aws_access_key`

    Configure the AWS access key for the Elasticsearch `discovery-ec2` and `repository-s3` plugins

- `aws_secret_key`

    Configure the AWS secret key for the Elasticsearch `discovery-ec2` and `repository-s3` plugins

- `logstash_config_bucket` 
    
    Configure the logstash config S3 bucket

- `bootstrap_password`

    Configure the bootstrap password for `elastic` user

- `elastic_password`

    Configure the password for `elastic` user

- `kibana_password`

    Configure the password for `kibana` user

- `logstash_system_password`

    Configure the password for `logstash_system` user

- `beats_system_password`

    Configure the password for `beats_system` user

- `apm_system_password`

    Configure the password for `apm_system` user

- `remote_monitoring_user_password`

    Configure the password for `remote_monitoring_user` user

- `logstash_internal_password`

    Configure the password for `logstash_internal` user

# Usage

- Configure attributes in your stack settings

- Add `elasticsearch` App with the environment variables mentioned above

- Add `elasticsearch` layer if you want a node with default roles

    - Add `elastic_opsworks::elasticsearch_setup` in the `Setup` lifecycle event
    - Set inter cluster security group

- Add `master` layer if you want a dedicated master nodes
    
    - Add `elastic_opsworks::elasticsearch_setup` in the `Setup` lifecycle event
    - Set inter cluster security group
    
- Add at least 2 nodes with `master` role by either adding 2 instances in either `elasticsearch` or `master` layer

- Add `data` layer if you want a dedicated data nodes

    - Add `elastic_opsworks::elasticsearch_setup` in the `Setup` lifecycle event
    - Set inter cluster security group
    - Setup client access security group

- Add `kibana` layer if you want a node kibana node

    - Add `elastic_opsworks::kibana_setup` in the `Setup` lifecycle event

- Add `logstash` layer if you want a node logstash node

    - Add `elastic_opsworks::logstash_setup` and `elastic_opsworks::logstash_sync_config` in the `Setup` lifecycle event
