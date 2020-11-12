require "kubes_google/version"
require "logger"

require "kubes_google/autoloader"
KubesGoogle::Autoloader.setup

module KubesGoogle
  class Error < StandardError; end

  @@logger = nil
  def logger
    @@logger ||= Kubes.logger
  end

  def logger=(v)
    @@logger = v
  end

  # Friendlier method configure.
  #
  #    .kubes/config/env/dev.rb
  #    .kubes/config/plugins/google.rb # also works
  #
  # Example:
  #
  #     KubesGoogle.configure do |config|
  #       config.hooks.gke_whitelist = true
  #     end
  #
  def configure(&block)
    Config.instance.configure(&block)
  end

  def config
    Config.instance.config
  end

  def cloudbuild?
    !!ENV['BUILDER_OUTPUT'] # cloudbuild env vars: https://gist.github.com/tongueroo/7ae26abd60d30da3972e86b4e7ca315e
  end

  extend self
end

Kubes::Plugin.register(KubesGoogle)
