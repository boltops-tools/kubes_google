class KubesGoogle::Secrets::Fetcher
  class Sdk < Base
    include KubesGoogle::Services

    def fetch(short_name, version="latest")
      value = fetch_value(short_name, version)
      value = Base64.strict_encode64(value).strip if base64?
      value
    end

    def fetch_value(short_name, version="latest")
      name = "projects/#{project_number}/secrets/#{short_name}/versions/#{version}"
      version = secret_manager_service.access_secret_version(name: name)
      version.payload.data
    rescue Google::Cloud::NotFoundError => e
      logger.info "WARN: secret #{name} not found".color(:yellow)
      logger.info e.message
      "NOT FOUND #{name}" # simple string so Kubernetes YAML is valid
    end

  private
    @@project_number = nil
    def project_number
      return @@project_number if @@project_number
      project = resource_manager.project(@project_id)
      @@project_number = project.project_number
    end
  end
end
