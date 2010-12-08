module Rdoctest
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 2
    BETA  = 'pre'

    VERSION = [MAJOR, MINOR, PATCH, BETA].compact.join('.').freeze
  end
end
