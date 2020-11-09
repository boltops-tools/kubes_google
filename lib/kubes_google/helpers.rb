module KubesGoogle
  module Helpers
    extend Memoist
    include Services

    def google_secret(name, options={})
      fetcher = Secrets::Fetcher.new(options)
      fetcher.fetch(name)
    end
  end
end
