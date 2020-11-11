module KubesGoogle::Util
  module Sh
  private
    def sh(command)
      logger.debug "=> #{command}"
      success = system(command)
      unless success
        logger.info "WARN: Running #{command}"
      end
      success
    end

    def capture(command)
      out = `#{command}`
      unless $?.exitstatus == 0
        logger.info "ERROR: Running #{command}"
        logger.info out
        exit 1
      end
      out
    end
  end
end
