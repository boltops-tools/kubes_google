module KubesGoogle
  module Helpers
    extend Memoist
    include Services

    def google_secret(name, options={})
      fetcher = Secrets::Fetcher.new(options)
      fetcher.fetch(name)
    end

    def google_secret_data(name, options={})
      generic_secret_data(:google_secret, name, options)
    end
  end
end
