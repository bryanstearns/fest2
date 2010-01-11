if false
  # Force ActionMailer to log the SMTP conversation, for debugging
  class DebugRelay
    def <<(msg)
      Rails.logger.info("SMTP: #{msg}")
    end
  end

  class Net::SMTP
    def start_with_logging(*args, &block)
      self.debug_output = DebugRelay.new
      self.start_without_logging(*args, &block)
    end
    alias_method_chain :start, :logging
  end
end
