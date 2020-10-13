require "google-cloud-secret_manager"

module KubesGoogle
  class Secrets
    def initialize(upcase: false, prefix: nil)
      @upcase = upcase
      @prefix = ENV['GCP_SECRET_PREFIX'] || prefix || raise("GOOGLE_PROJECT env variable is not set. It's required.")
      @project_id = ENV['GOOGLE_PROJECT']
      # IE: prefix: projects/686010496118/secrets/demo-dev-
    end

    def call
      client = Google::Cloud::SecretManager.secret_manager_service

      parent = "projects/#{@project_id}"
      resp = client.list_secrets(parent: parent, page_size: 1)
      resp.each do |secret|
        next unless secret.name.include?(@prefix)
        version = client.access_secret_version(name: "#{secret.name}/versions/latest")

        # projects/686010496118/secrets/demo-dev-db_pass => DB_PASS
        key = secret.name.sub(@prefix,'')
        key = key.upcase if @upcase
        value = version.payload.data
        self.class.data[key] = value
      end
    end

    class_attribute :data
    self.data = {}
  end
end
