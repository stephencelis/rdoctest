require 'rake'
require 'rake/tasklib'

module Rdoctest
  # See the README for more information.
  class Task < Rake::TaskLib
    # :enddoc:
    attr_accessor :libs
    attr_accessor :name
    attr_accessor :options
    attr_accessor :pattern
    attr_accessor :ruby_opts
    attr_accessor :test_files
    attr_accessor :verbose
    attr_accessor :warning

    def initialize name = :doctest
      @libs       = %w(lib)
      @name       = name
      @options    = nil
      @pattern    = nil
      @ruby_opts  = []
      @test_files = nil
      @verbose    = false
      @warning    = false
      yield self if block_given?
      @pattern    = 'lib/**/*.rb' if @pattern.nil? && @test_files.nil?
      define
    end

    def define
      desc name ? "Run doctests for #{name}" : 'Run doctests'
      task name do
        ruby "#{run_code} #{ruby_opts_string} #{file_list_string}"
      end
    end

    private

    def ruby_opts_string
      opts = []
      opts << %(-I"#{lib_path}") unless libs.empty?
      opts << %(-w) if warning
      opts.concat ruby_opts
      opts.join ' '
    end

    def lib_path
      libs.join File::PATH_SEPARATOR
    end

    def run_code
      $LOAD_PATH.each do |path|
        file = File.join path, 'rdoctest'
        return file if File.executable?(file)
      end
    end

    def file_list_string
      file_list.join ' '
      # Dir[*file_list].join ' '
    end

    def file_list
      if ENV['TEST']
        Dir[ENV['TEST']]
      else
        result = []
        result += test_files.to_a if test_files
        result << pattern if pattern
        result
      end
    end

    def options_list
      ENV['TESTOPTS'] || @options
    end
  end
end
