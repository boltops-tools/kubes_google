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
      if ENV['KUBES_MOCK_SECRET']
        logger.info "KUBES_MOCK_SECRET=1 is set. Mocking secret: #{short_name}" unless ENV['KUBES_MOCK_SECRET_QUIET']
        @@cache[short_name] = "mock"
      else
        logger.debug "Fetching secret: #{short_name}"
        @@cache[short_name] = fetcher.fetch(short_name)
      end
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
