class KubesGoogle::Secrets::Fetcher
  class Base
    include KubesGoogle::Logging

    def initialize(options={})
      @options = options
      @base64 = options[:base64]
      @project_id = options[:google_project] || ENV['GOOGLE_PROJECT'] || raise("GOOGLE_PROJECT env variable is not set. It's required.")
    end

    def base64?
      @base64.nil? ? KubesGoogle.config.secrets.base64 : @base64
    end
  end
end
