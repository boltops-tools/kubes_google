module KubesGoogle
  module Helpers
    extend Memoist
    include KubesGoogle::Services

    @@google_secrets_fetcher = nil
    def google_secret(name)
      @@google_secrets_fetcher ||= KubesGoogle::Secrets::Fetcher.new
      @@google_secrets_fetcher.fetch(name)
    end
  end
end
