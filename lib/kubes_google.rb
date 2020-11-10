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

  # Friendlier method for .kubes/config/plugins/google.rb. Example:
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

  extend self
end

Kubes::Plugin.register(KubesGoogle)
