class KubesGoogle::Secrets
  class Fetcher
    extend Memoist
    include KubesGoogle::Logging
    include KubesGoogle::Services

    def initialize
      @project_id = ENV['GOOGLE_PROJECT'] || raise("GOOGLE_PROJECT env variable is not set. It's required.")
      # IE: prefix: projects/686010496118/secrets/demo-dev-
    end

    def fetch(short_name)
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
    def project_number
      parent = "projects/#{@project_id}"
      resp = secret_manager_service.list_secrets(parent: parent) # note: page_size doesnt seem to get respected
      name = resp.first.name # IE: projects/686010496118/secrets/demo-dev-db_host
      name.split('/')[1]
    end
    memoize :project_number
  end
end
