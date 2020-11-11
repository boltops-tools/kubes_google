class KubesGoogle::Secrets
  class Fetcher
    include KubesGoogle::Logging
    include KubesGoogle::Services

    def initialize(options={})
      @options = options
      @base64 = options[:base64]
      @project_id = ENV['GOOGLE_PROJECT'] || raise("GOOGLE_PROJECT env variable is not set. It's required.")
    end

    def fetch(short_name)
      value = fetch_value(short_name)
      value = Base64.strict_encode64(value).strip if base64?
      value
    end

    def base64?
      @base64.nil? ? KubesGoogle.config.base64_secrets : @base64
    end

    def fetch_value(short_name)
      name = "projects/#{project_number}/secrets/#{short_name}/versions/latest"
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
    end
  end
end
