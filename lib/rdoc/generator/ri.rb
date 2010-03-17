require 'rdoc/generator'
require 'rdoc/ri'

class RDoc::Generator::RI

  RDoc::RDoc.add_generator self

  def self.for options
    new options
  end

  ##
  # Set up a new ri generator

  def initialize options #:not-new:
    @options  = options
    @store    = RDoc::RI::Store.new '.'
    @old_siginfo = nil
    @current = nil
  end

  ##
  # Build the initial indices and output objects based on an array of TopLevel
  # objects containing the extracted information.

  def generate top_levels
    install_siginfo_handler

    RDoc::TopLevel.all_classes_and_modules.each do |klass|
      @current = "#{klass.class}: #{klass.full_name}"

      @store.save_class klass

      klass.each_method do |method|
        @current = "#{method.class}: #{method.full_name}"
        @store.save_method klass, method
      end
    end

    @current = 'saving cache'

    @store.save_cache

  ensure
    @current = nil

    remove_siginfo_handler
  end

  def install_siginfo_handler
    return unless Signal.list.key? 'INFO'

    @old_siginfo = trap 'INFO' do
      puts @current if @current
    end
  end

  def remove_siginfo_handler
    return unless @old_siginfo

    trap 'INFO', @old_siginfo
  end

end

