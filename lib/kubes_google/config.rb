module KubesGoogle
  class Config
    include Singleton

    def defaults
      c = ActiveSupport::OrderedOptions.new
      c.base64_secrets = true
      c.gke = ActiveSupport::OrderedOptions.new
      c.gke.cluster_name = nil
      c.gke.enable_get_credentials = nil
      c.gke.enable_hooks = nil # nil since need cluster_name also. setting to false will explicitly disable hooks
      c.gke.google_project = nil
      c.gke.google_region = nil
      c.gke.whitelist_ip = nil # default will auto-detect IP
      c
    end

    @@config = nil
    def config
      @@config ||= defaults
    end

    def configure
      yield(config)
    end
  end
end
