module Cerializable
  module ActsAsCerializable
    extend ActiveSupport::Concern

    included do
      # redefine #serializable_hash to delegate to the serializer object's #run method.
      # ensure it still supports the :only, :except, and :methods serialization options.
      def serializable_hash(options = {})
        exception_message = "Cannot pass both 'only' & 'except' options to #{ self.class.name.downcase }#serializable_hash."
        raise Exception, exception_message if options[:only] && options[:except]

        [:only, :except, :methods].each do |option_name|
          option_is_array = options[option_name].class.ancestors.include?(Array)
          option_is_symbol = options[option_name].class.ancestors.include?(Symbol)
          invalid_option_passed = options[option_name] && !option_is_array && !option_is_symbol
          raise Exception, "'#{ option_name }' option must be of an Array or Symbol class." if invalid_option_passed
        end

        # serialize the instance using the class's serializer object.
        hash = self.class.serializer.run(self, options)

        # now, alter the hash according to the :only, :except, and :methods serialization options.
        ensure_is_array = proc { |arg| arg.class.ancestors.include?(Array) ? arg : Array.new(1, arg) }

        if except_options = options[:except] && ensure_is_array.call(options[:except])
          except_options.each { |key| hash.delete(key) }
        end

        if only_options = options[:only] && ensure_is_array.call(options[:only])
          hash.keys.each { |key| hash.delete(key) unless only_options.include?(key) }
        end

        if methods_options = options[:methods] && ensure_is_array.call(options[:methods])
          methods_options.each { |method_name| hash[method_name] = self.send(method_name) unless hash[method_name] }
        end

        hash
      end

      # redefine #as_json and #to_json to delegate to #serializable_hash
      def as_json(options = {}); serializable_hash(options) end
      def to_json(options = {}); serializable_hash(options) end
    end

    module ClassMethods
      def acts_as_cerializable(options = {})
        Cerializable.setup(options.merge(base: self))
      end
    end

  end
end

ActiveRecord::Base.send :include, Cerializable::ActsAsCerializable
