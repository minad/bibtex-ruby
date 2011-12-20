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
    
    alias convert apply
    alias << apply
    
  end
  
  module Filters
    LOAD_PATH = [File.expand_path('..', __FILE__), 'filters'].join('/').freeze

    Dir.glob("#{LOAD_PATH}/*.rb").each do |filter|
      require filter
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

