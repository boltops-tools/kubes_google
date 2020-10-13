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

  extend self
end
