require 'test/unit'

module Rdoctest
  class TestCase < Test::Unit::TestCase
    private

    def assert_eval expected, result, filename, lineno
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
