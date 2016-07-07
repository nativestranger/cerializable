module Cerializable
  module ActsAsCerializable
    extend ActiveSupport::Concern

    included do
      # #serializable_hash delegates to the #run method of the model's serializer module.
      #
      # It accepts `:only`, `:except`, and `:methods` options which can be passed as a single
      # symbol ors as an array of symbols. Using both the `:only` and `:except` options will
      # raise an exception.
      #
      # Using the `:only` option will return a hash that only has the specified keys.
      #
      #     > comment.serializable_hash(only: :id)
      #     => { id: 1 }
      #
      # Using the `:except` option will return a hash that has all default keys except those specified.
      #
      #     > comment.serializable_hash(except: [:id, :user_id])
      #     => { body: '...sushi?', deleted_at: nil }
      #
      # Using the `:methods` option will add keys to the hash for each method specified.
      #
      #     > comment.serializable_hash(only: id, methods: :hash])
      #     => { id: 1, hash: -2535926706119161824 }
      #
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

      # #as_json delegates to #serializable_hash
      def as_json(options = {}); serializable_hash(options) end
      # #to_json delegates to #serializable_hash
      def to_json(options = {}); serializable_hash(options) end
    end

    module ClassMethods
      # `acts_as_cerializable` is used to declare that a
      # model uses Cerializable for serialization.
      #
      # Unless a module is specified via the
      # +serialize_with+ option, the serializer will attempt
      # to include a module based on the model's name.
      #
      # For example, calling +Comment.acts_as_cerializable+ without a +serialize_with+
      # option will cause Cerializable to look for a +CommentSerializer+ module when
      # setting up the Comment model's serializer.
      #
      # Calling +Comment.acts_as_cerializable+ +serialize_with:+ +MySerializer+
      # will cause Cerializable to look for a +MySerializer+ module when
      # setting up the Comment model's serializer.
      def acts_as_cerializable(options = {})
        Cerializable.setup(options.merge(base: self))
      end
    end

  end
end

ActiveRecord::Base.send :include, Cerializable::ActsAsCerializable
