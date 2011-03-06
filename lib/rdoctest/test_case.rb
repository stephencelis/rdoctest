require 'test/unit'

module Rdoctest
  class TestCase < Test::Unit::TestCase
    private

    define_method :assert_eval do |expected, result, filename, lineno|
      if expected.gsub!(/\.{3,}/, '.*')
        assertion, expected = 'match', /#{expected}/
      else
        assertion = 'equal'
      end

      instance_eval <<ASSERTION, filename, lineno
assert_#{assertion} #{expected.inspect}, #{result.inspect}
ASSERTION
    end
  end
end
