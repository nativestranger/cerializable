require 'cerializable/cerializer'
require 'cerializable/acts_as_cerializable'

module Cerializable

  def self.setup(options) # :nodoc:
    # evaluate code in the context of the base class
    options[:base].class_eval do

      # define a 'serializer' class method on the base class.
      # it returns a serializer object which does the serialization for instances of the class.
      define_singleton_method :serializer, proc {
        @serializer ||= Cerializer.new.tap do |serializer|
          serializer_module = options[:serialize_with] || "#{ options[:base].name  }Serializer".constantize
          # use class_eval to include the serializer module in the serializer's eigenclass
          serializer.class_eval { include serializer_module }
        end
      }

    end
  end

end
