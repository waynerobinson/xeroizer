module Xeroizer
  module Logging
    class DevNullLog; def self.info(what); end; end
    class StdOutLog; def self.info(what); puts what; end; end

    Log = DevNullLog
  end
end
