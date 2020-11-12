class KubesGoogle::Secrets
  class Fetcher
    extend Memoist

    def initialize(options={})
      @options = options
    end

    def fetch(short_name)
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
