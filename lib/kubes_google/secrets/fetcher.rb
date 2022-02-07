class KubesGoogle::Secrets
  class Fetcher
    include KubesGoogle::Logging
    extend Memoist

    def initialize(options={})
      @options = options
    end

    @@cache = {}
    def fetch(short_name)
      return @@cache[short_name] if @@cache[short_name]
      logger.debug "Fetching secret: #{short_name}"
      @@cache[short_name] = fetcher.fetch(short_name)
    rescue KubesGoogle::VpnSslError
      logger.info "Retry fetching secret with the gcloud strategy"
      fetcher = Gcloud.new(@options)
      fetcher.fetch(short_name)
    end

    def fetcher
      if KubesGoogle.config.secrets.fetcher == "sdk"
        Sdk.new(@options)
      else
        Gcloud.new(@options)
      end
    end
    memoize :fetcher
  end
end
