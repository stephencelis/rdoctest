require 'stringio'
require 'strscan'
require 'rdoctest/test_case'

module Rdoctest
  # The Runner takes RDoc example text and creates tests for them.
  #
  # ==== Example
  #
  # Writing inline code that ends with <tt># =></tt> and the result will create
  # an assertion that the code evaluation is equal to that result.
  #
  #   1 + 1
  #   # => 2
  #
  # You can also write an assertion on a single line.
  #
  #   2 + 2 # => 4
  #
  # If you want to assert errors or output, mimic an IRB session.
  #
  #   >> puts 'hello world'
  #   hello world
  #   => nil
  #   >> def ok
  #   >>   a
  #   >> end
  #   => nil
  #
  # Use ellipses for partial matches.
  #
  #   >> ok
  #   NameError: undefined local variable or method `a'...
  class Runner
    @@ruby = /(.+?)# =>([^\n]+\n)/m
    @@irb  = /((?:^>> [^\n]+\n)+)((?:(?!^(?:>>|=>))[^\n]+\n)*)(^=> [^\n]+)?/m

    attr_reader :files, :options

    def initialize options = {}
      @options = options

      @files = {}
    end

    def run
      parse
      execute
    end

    private

    def parse
      filename = lineno = in_comment = in_test = nil

      ARGF.each do |line|
        lineno, filename = 0, ARGF.filename if filename != ARGF.filename
        lineno += 1

        next in_comment = nil unless line.sub! /^ *# ?/, ''
        in_comment   = lineno if line =~ /^={1,6} \S/
        in_comment ||= lineno

        if in_test
          in_test = false if line !~ /^(?: {2,}|$)/
        else
          in_test = true  if line =~ /^ {2}\S/
        end

        line = "\n" unless in_test
        ((files[filename] ||= {})[in_comment] ||= '') << line if in_comment
      end
    end

    def execute
      files.each_pair do |filename, lineno_and_lines|
        class_name = File.basename(filename, '.rb')
        class_name.gsub!(/(?:^|_)(\w+:{,2})/) { |r| r.capitalize }
        class_name.gsub! /\W+/, ''
        class_name = 'Rdoctest' if class_name.empty?
        require_filename filename

        test_class = Class.new Rdoctest::TestCase do
          lineno_and_lines.each_pair do |lineno, lines|
            next unless lines =~ /\S/ # /(?:^|# )=>/
            lines.gsub! /^  /, ''

            define_method "test_line_#{lineno}" do
              scanner = StringScanner.new lines

              binding = send :binding
              while scanner.skip_until(@@ruby)
                code_lineno = lineno + scanner.pre_match.count("\n")
                expected_lineno = code_lineno + scanner[1].count("\n")

                result = eval scanner[1], binding
                assert_eval scanner[2].strip, result.inspect, filename,
                  expected_lineno
              end
              scanner.pos = 0

              while scanner.skip_until(@@irb)
                code_lineno = lineno + scanner.pre_match.count("\n")
                output_lineno = code_lineno + scanner[2].to_s.count("\n")
                expected_lineno = output_lineno + scanner[3].to_s.count("\n")

                begin
                  stdout, $stdout = $stdout, StringIO.new
                  result = eval scanner[1].gsub(/^>> /, ''), binding
                rescue => e
                  puts "#{e.class}: #{e}"
                ensure
                  $stdout, stdout = stdout, $stdout
                end

                stdout.rewind
                output = stdout.read
                unless output.empty?
                  assert_eval scanner[2], output, filename, output_lineno
                end

                if scanner[3]
                  expected = scanner[3].sub(/^=> /, '').strip
                  assert_eval expected, result.inspect, filename,
                    expected_lineno
                end
              end
            end
          end
        end

        Object.const_set "#{class_name}Test", test_class
      end
    end

    def require_filename filename
      return if filename == '-'
      load_path = options[:load_path].join '|'
      require filename.gsub(%r{^(?:#{load_path})/|.rb$}, '')
    end
  end
end
