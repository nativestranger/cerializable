module Cerializable
  module ActsAsCerializable
    extend ActiveSupport::Concern

    included do
      # #serializable_hash delegates to the #run method of the model's 'cerializer' object.
      #
      # It accepts `:only`, `:except`, and `:methods` options which can be passed as a
      # symbol or as an array of symbols.
      #
      # Using the `:only` option will return a hash that only has the specified keys.
      #
      #     > comment.serializable_hash(only: :id)
      #     => { id: 1 }
      #
      # Using the `:except` option will return a hash that has all default keys except those specified.
      #
      #     > comment.serializable_hash(except: [:id, :user_id])
      #     => { body: '...sushi? ;)', deleted_at: nil }
      #
      # Using the `:methods` option add will add a key and value for each method specified.
      #
      # The key is the method name as a symbol.
      # The value is the return value given when calling the method on the model instance.
      #
      # The :methods option is processed after the :only and :except options.
      #
      #     > comment.serializable_hash(only: id, methods: :hash])
      #     => { id: 1, hash: -2535926706119161824 }
      #
      def serializable_hash(options = {})
        [:only, :except, :methods].each do |option_name|
          break if options[:option_name].nil?

          unless options[:option_name].is_a?(Symbol) || options[:option_name].is_a?(Array)
            raise Exception, "'#{ option_name }' option must be of an Array or Symbol class."
          end
        end

        # serialize the instance using the class's cerializer object.
        hash = self.class.cerializer.run(self, options)

        # alter the hash according to the :only, :except, and :methods serialization options.
        ensure_is_array = proc { |arg| arg.class.ancestors.include?(Array) ? arg : Array.new(1, arg) }

        if except_options = options[:except] && ensure_is_array.call(options[:except])
          except_options.each { |key| hash.delete(key) }
        end

        if only_options = options[:only] && ensure_is_array.call(options[:only])
          hash.keys.each { |key| hash.delete(key) unless only_options.include?(key) }
        end

        if methods_options = options[:methods] && ensure_is_array.call(options[:methods])
          methods_options.each { |method_name| hash[method_name] = self.send(method_name) }
        end

        hash
      end

      alias :as_json :serializable_hash
      alias :to_json :serializable_hash
    end

    module ClassMethods
      # `acts_as_cerializable` is used to declare that a
      # model uses Cerializable for serialization.
      #
      # Unless a module is specified via the
      # +serialize_with+ option, the base model's cerializer will attempt
      # to include a module based on the model's name.
      #
      # For example, calling +Comment.acts_as_cerializable+ without a +serialize_with+
      # option will cause Cerializable to look for a +CommentSerializer+.
      #
      # Calling +Comment.acts_as_cerializable+ +serialize_with:+ +MySerializer+
      # will cause Cerializable to look for a +MySerializer+ instead.
      def acts_as_cerializable(options = {})
        Cerializable.setup(options.merge(base: self))
      end
    end

  end
end

ActiveRecord::Base.send :include, Cerializable::ActsAsCerializable
