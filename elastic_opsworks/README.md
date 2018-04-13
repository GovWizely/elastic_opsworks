# elastic stack in OpsWorks Cookbook

- Install and configure elastic stack in OpsWorks

# Requirements

- AWS OpsWorks with Chef 12
- AWS credentials with IAM policy to access [S3 and EC2](elastic_aws_cloud_plugin_policy.json)
- AWS security group for inter cluster communication on port `9200` and `9300`
- AWS security group for client access to the `data` nodes on port `9200`
- AWS security group for kibana nodes on port `5601`
- Datadog API and application keys

# Stack settings

- Default operating system: Amazon Linux 2017.09

- Custom JSON:

  - Datadog API and application keys

  ```json
  {
    "datadog": {
      "api_key": "CHANGE_ME_DATADOG_API_KEY",
      "application_key": "CHANGE_ME_DATADOG_APPLICATION_KEY"
    }
  }
  ```

  - The default datadog env tag is `production`. To override this value, append the following JSON:

    ```json
    {
      "datadog": {
        "tags": {
          "env": "staging"
        }
      }
    }
    ```

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

- `elastic_password`

    Configure the password for `elastic` user
    Required if `node['elastic_opsworks']['xpack']['enabled']` is `true`

- `kibana_username`

    Configure the `elasticsearch.username` in `kibana.yml`
    Required if `node['elastic_opsworks']['xpack']['enabled']` is `true`

- `kibana_password`

    Configure the `elasticsearch.password` in `kibana.yml`
    Required if `node['elastic_opsworks']['xpack']['enabled']` is `true`

- `logstash_system_password`

    Configure the password for `logstash_system` user
    Required if `node['elastic_opsworks']['xpack']['enabled']` is `true`

# Attributes

- `node['elastic_opsworks']['elasticsearch']['cluster.name']` - Configure elasticsearch cluster name (REQUIRED)
- `node['elastic_opsworks']['elasticsearch']['allocated_memory']` - Override the default allocated memory
- `node['elastic_opsworks']['elasticsearch']['custom_configuration']` - Add additional key value pairs configuration in `elasticsearch.yml`
- `node['elastic_opsworks']['xpack']['enabled']` - `true` by default

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

- If you have `node['elastic_opsworks']['xpack']['enabled']` set to `true`

    - Run `elastic_opsworks::change_default_password` on a node with `data` role

    - Add `kibana` layer
    
        - Add `elastic_opsworks::kibana_setup` in the `Setup` lifecycle event
        - Set inter cluster security group
        - Set ELB to kibana security group
    
    - Login to kibana and update the license
