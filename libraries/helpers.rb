module ElasticsearchCookbook
  # Helper methods included by various providers and passed to the template engine
  module Helpers
    def find_es_resource(run_context, resource_type, resource)
      return elasticsearch_service_open_struct if resource_type == :elasticsearch_service

      resource_name = resource.name
      instance_name = resource.instance_name

      # if we are truly given a specific name to find
      name_match = find_exact_resource(run_context, resource_type, resource_name) rescue nil
      return name_match if name_match

      # first try by instance name attribute
      name_instance = find_instance_name_resource(run_context, resource_type, instance_name) rescue nil
      return name_instance if name_instance

      # otherwise try the defaults
      name_default = find_exact_resource(run_context, resource_type, 'default') rescue nil
      name_elasticsearch = find_exact_resource(run_context, resource_type, 'elasticsearch') rescue nil

      # if we found exactly one default name that matched
      return name_default if name_default && !name_elasticsearch
      return name_elasticsearch if name_elasticsearch && !name_default

      raise "Could not find exactly one #{resource_type} resource, and no specific resource or instance name was given"
    end

    def elasticsearch_service_open_struct
      OpenStruct.new(service_name: 'elasticsearch')
    end
  end
end
