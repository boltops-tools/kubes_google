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

    # TODO: Get the project from the list project api instead. Unsure where the docs are for this.
    # If someone knows, let me know.
    # Right now grabbing the first secret to then be able to get the google project number
    @@project_number = nil
    def project_number
      return @@project_number if @@project_number

      parent = "projects/#{@project_id}"
      resp = secret_manager_service.list_secrets(parent: parent) # note: page_size doesnt seem to get respected
      name = resp.first.name # IE: projects/686010496118/secrets/demo-dev-db_host
      @@project_number = name.split('/')[1]
    rescue Google::Cloud::UnavailableError => e
      logger.error "ERROR: #{e.message}"
      if e.message.include?("failed to connect")
        logger.info <<~EOL
          SSL Handshake failed. This error seems to happen with some VPN setups.
          Please try the gcloud fetcher instead. To set up see:

            https://kubes.guru/docs/helpers/google/secrets/#fetcher-strategy
        EOL
        exit 1
      else
        raise
      end
    end
  end
end
