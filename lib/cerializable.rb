require 'cerializable/cerializer'
require 'cerializable/model'

module Cerializable

  def self.setup(options) # :nodoc:
    # evaluate code in the context of the base class
    options[:base].class_eval do

      # define a 'cerializer' class method on the base class.
      # it returns a cerializer object which does the serialization for instances of the class.
      define_singleton_method :cerializer, proc {
        @cerializer ||= Cerializer.new.tap do |cerializer|
          serializer_module = options[:serialize_with] || "#{ options[:base].name  }Serializer".constantize
          # use class_eval to include the serializer module in the cerializer's eigenclass
          cerializer.class_eval { include serializer_module }
        end
      }

    end
  end

end
