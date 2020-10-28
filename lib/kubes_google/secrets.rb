require "google-cloud-secret_manager"

module KubesGoogle
  class Secrets
    def initialize(upcase: false, base64: false, prefix: nil)
      @upcase, @base64 = upcase, base64
      @prefix = ENV['GCP_SECRET_PREFIX'] || prefix
      @project_id = ENV['GOOGLE_PROJECT'] || raise("GOOGLE_PROJECT env variable is not set. It's required.")
      # IE: prefix: projects/686010496118/secrets/demo-dev-
    end

    def call
      client = Google::Cloud::SecretManager.secret_manager_service

      parent = "projects/#{@project_id}"
      resp = client.list_secrets(parent: parent) # note: page_size doesnt seem to get respected
      resp.each do |secret|
        next unless secret.name.include?(@prefix)
        version = client.access_secret_version(name: "#{secret.name}/versions/latest")

        # projects/686010496118/secrets/demo-dev-db_pass => DB_PASS
        key = secret.name.sub(@prefix,'')
        key = key.upcase if @upcase
        value = version.payload.data
        # strict_encode64 to avoid newlines https://stackoverflow.com/questions/2620975/strange-n-in-base64-encoded-string-in-ruby
        value = Base64.strict_encode64(value).strip if @base64
        self.class.data[key] = value
      end
    end

    def data
      self.class.data
    end

    class_attribute :data
    self.data = {}
  end
end
