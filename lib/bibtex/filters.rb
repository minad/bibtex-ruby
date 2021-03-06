require 'singleton'

module BibTeX
  class Filter
    include Singleton

    class << self
      # Hook called by Ruby if Filter is subclassed
      def inherited(base)
        base.class_eval { include Singleton }
        subclasses << base
      end

      # Returns a list of all current Filters
      def subclasses
        @subclasses ||= []
      end
    end

    def apply(value)
      value
    end

    alias_method :convert, :apply
    alias_method :<<, :apply
  end

  module Filters
    LOAD_PATH = File.join(File.dirname(__FILE__), 'filters').freeze

    Dir.glob("#{LOAD_PATH}/*.rb").each do |filter|
      begin
        require filter
      rescue LoadError
        # ignore
      end
    end

    def self.resolve!(filter)
      resolve(filter) || raise(ArgumentError, "Failed to load filter #{filter.inspect}")
    end

    def self.resolve(filter)
      case
      when filter.respond_to?(:apply)
        filter
      when filter.respond_to?(:to_s)
        klass = Filter.subclasses.detect do |c|
          c.name == filter.to_s || c.name.split(/::/)[-1] =~ /^#{filter}$/i
        end
        klass && klass.instance
      else
        nil
      end
    end
  end
end

