module VacuumCleaner

  # @private
  # Suffix added to existing setter methods
  WITHOUT_NORMALIZATION_SUFFIX = "_without_normalization"
  
  # Base module required to be included in 
  #
  module Normalizations
    
    def self.included(base)
      base.extend(ClassMethods)
    end
        
    module ClassMethods
      
      # List of already normalized attributes, to keep everything safe
      # when calling `normalizes` twice for a certain attribute.
      #
      # When called for the first time checks it's `superclass` for any
      # normalized attributes.
      def normalized_attributes
        @normalized_attributes ||= [].tap do |ary|
          superclass.normalized_attributes.each { |a| ary << a } if superclass && superclass.respond_to?(:normalized_attributes)
        end
      end
      
      # Enables normalization chain for supplied attributes.
      #
      # @example Basic usage for plain old ruby objects.
      #   class Doctor
      #     include VacuumCleaner::Normalizations
      #     attr_accessor :name      
      #     normalizes :name
      #   end
      #
      # 
      # @param [Strings, Symbols] attributes list of attribute names to normalize, at least one attribute is required
      # @param [Hash] options optional list of normalizers to use, like +:downcase => true+. To not run the default
      #        normalizer ({VacuumCleaner::Normalizer#normalize_value}) set +:default => false+
      #
      # @yield [value] optional block to define some one-time custom normalization logic
      # @yieldparam value can be +nil+, otherwise value as passed through the default normalizer
      # @yieldreturn should return value as normalized by the block
      #
      # @yield [instance, attribute, value] optional (extended) block with all arguments, like the +object+ and
      #        current +attribute+ name. Everything else behaves the same es the single-value +yield+
      def normalizes(*attributes, &block)
        normalizations = attributes.last.is_a?(Hash) ? attributes.pop : {}
        raise ArgumentError, "You need to supply at least one attribute" if attributes.empty?
        
        normalizers = []
        normalizers << Normalizer.new unless normalizations.delete(:default) === false
        
        normalizations.each do |key, options|
          begin
            normalizers << const_get("#{VacuumCleaner.camelize_value(key)}Normalizer").new(options === true ? {} : options)
          rescue NameError
            raise ArgumentError, "Unknown normalizer: '#{key}'"
          end
        end
        
        attributes.each do |attribute|
          attribute = attribute.to_sym
          
          # guard against calling it twice!
          unless normalized_attributes.include?(attribute)
            send(:define_method, :"normalize_#{attribute}") do |value|
              value = normalizers.inject(value) { |v,n| n.normalize(self, attribute, v) }
              block_given? ? (block.arity == 1 ? yield(value) : yield(self, attribute, value)) : value
            end
            original_setter = "#{attribute}#{VacuumCleaner::WITHOUT_NORMALIZATION_SUFFIX}=".to_sym
            send(:alias_method, original_setter, "#{attribute}=") if instance_methods.include?(RUBY_VERSION =~ /^1.9/ ? :"#{attribute}=" : "#{attribute}=")
                    
            class_eval <<-RUBY, __FILE__, __LINE__+1
              def #{attribute}=(value)                                                                          #  1.  def name=(value)
                value = send(:'normalize_#{attribute}', value)                                                  #  2.    value = send(:'normalize_name', value)
                return send(#{original_setter.inspect}, value) if respond_to?(#{original_setter.inspect})       #  3.    return send(:'name_wi...=', value) if respond_to?(:'name_wi...=')
                return send(:[]=, #{attribute.inspect}, value) if respond_to?(:[]=)                             #  4.    return send(:[]=, :name, value) if respond_to?(:[]=)
                @#{attribute} = value                                                                           #  5.   @name = value
              end                                                                                               #  6.  end
            RUBY
            
            normalized_attributes << attribute
          end
        end
      end      
    end    
  end
  
  # @private
  # Okay, because this library currently does not depend on
  # <tt>ActiveSupport</tt> or anything similar an "independent" camelizing process is
  # required.
  #
  # <b>How it works:</b> If <tt>value.to_s</tt> responds to <tt>:camelize</tt>, then call it else, use implementation
  # taken from http://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L25
  def camelize_value(value)
    value = value.to_s
    value.respond_to?(:camelize) ? value.camelize : value.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
  module_function :camelize_value
end

# load standard normalizations
Dir[File.dirname(__FILE__) + "/normalizations/*.rb"].sort.each do |path|
  require "vacuum_cleaner/normalizations/#{File.basename(path)}"
end