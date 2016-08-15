= Cerializable

Custom serialization for Rails models.

Add Cerializable to your Gemfile:

    gem 'cerializable', '~> 0.0.2'

Call 'acts_as_cerializable' in the models you wish to use Cerializable with:

    class Comment < ApplicationRecord
      acts_as_cerializable
    end

Define corresponding serializer modules:

    module CommentSerializer

      def run(comment, options)
        { id: comment.id,
          user_id: comment.user_id,
          body: comment.body,
          ancestorCount: comment.ancestor_count,
          childComments: options[:children] || comment.child_comments.map { |c| c.serializable_hash }
      end

    end

If you wish, you can specify a serializer module to use:

    class Comment < ApplicationRecord
      acts_as_cerializable serialize_with: SomeSerializerModule
    end


The only requirement is that the serializer modules have a 'run' method which accepts two arguments and returns a hash detailing how instances of your model should be serialized.

Your model's #as_json, #to_json, and #serializable_hash methods will use the #run method of their serializer to produce their results.

They accept `:only`, `:except`, and `:methods` options which can be passed as a
symbol or as an array of symbols.

Using the `:only` option will return a hash that only has the specified keys:

    > comment.serializable_hash(only: :id)
    => { id: 1 }

Using the `:except` option will return a hash that has all default keys except those specified:

    > comment.serializable_hash(except: [:user_id, :ancestorCount, :childComments])
    => { id: 1, body: '...sushi? ' }

Using the `:methods` option add will add a key and value for each method specified.

The key is the method name and the value is the return value given when calling the method on the model instance.

The `:methods` option is processed after the `:only` and `:except` options:

    > comment.serializable_hash(only: id, methods: :hash])
    => { id: 1, hash: -2535926706119161824 }

You can also pass in custom options that your serializer modules make use of.

For example, the class below allows us to build a comment thread's hierarchy without making queries for each comment's children:

  class CommentTreeService

    def initialize
      @comments_hash = {}
      @result = []

      @children_resolver = proc do |parent_comment|
        children_array = []
        @comments_hash.each_pair do |id, comment|
          if comment.parent_type == 'Comment' && comment.parent_id == parent_comment.id
            @comments_hash.delete(id)
            children_array << comment.serializable_hash(children: @children_resolver.call(comment))
          end
        end
        children_array
      end
    end

    def for_thread(comment_thread, options = { order: { ancestor_count: :asc, id: :desc } })
      comment_thread.comments
        .order(options[:order]).each { |comment| @comments_hash[comment.id] = comment }

      @comments_hash.each_pair do |id, comment|
        if comment.parent_type == 'CommentThread'
          @comments_hash.delete(id)
          @result << comment.serializable_hash(children: @children_resolver.call(comment))
        end
      end

      @result
    end

  end

TODO:

* Support #to_xml
