require "google-cloud-secret_manager"
require "google/cloud/container"

module KubesGoogle
  module Services
    extend Memoist

    def cluster_manager
      Google::Cloud::Container.cluster_manager
    end
    memoize :cluster_manager

    def secret_manager_service
      Google::Cloud::SecretManager.secret_manager_service
    end
    memoize :secret_manager_service
  end
end

