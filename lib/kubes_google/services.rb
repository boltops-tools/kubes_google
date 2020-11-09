require "google-cloud-secret_manager"

module KubesGoogle
  module Services
    extend Memoist

    def secret_manager_service
      Google::Cloud::SecretManager.secret_manager_service
    end
    memoize :secret_manager_service
  end
end

