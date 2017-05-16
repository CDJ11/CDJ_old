module Polymorphic

  private

    def resource
      @resource ||= instance_variable_get("@#{resource_name}")
    end

    def resource_name
      @resource_name ||= resource_model.to_s.downcase
    end

    def set_resource_instance
      instance_variable_set("@#{resource_name}", @resource)
    end

    def set_resources_instance
      instance_variable_set("@#{resource_name.pluralize}", @resources)
    end

    def strong_params
      send("#{resource_name}_params")
    end

end