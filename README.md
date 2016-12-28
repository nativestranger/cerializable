# Cerializable

Plain old Ruby serialization for Ruby objects.

## Code Status

[![Build Status](https://travis-ci.org/nativestranger/cerializable.svg?branch=master)](https://travis-ci.org/nativestranger/cerializable)

Rather than using something like jbuilder, you could use cerializable to generate hashes for your model instances and then render the hashes as JSON. This can aid in performance.

It also gives you the option to customize the process via custom serialization options.

## Installation

For use with ActiveRecord, simply add cerializable to your Gemfile:

    gem 'cerializable', '~> 0.2.0'

For other ORMs, you'll also need to include `Cerializable::Model` in your ORM's base class.

## Usage

Call `cerializable` in the models you wish to use Cerializable with:

    class Comment < ApplicationRecord
      cerializable
    end

Define corresponding serializer modules:

    module CommentSerializer

      def run(comment, options)
        { id: comment.id,
          userId: comment.user_id,
          body: comment.body,
          ancestorCount: comment.ancestor_count,
          childComments: options[:children] || comment.child_comments.map { |c| c.cerializable_hash }
      end

    end

If you wish, you can specify a serializer module to use:

    class Comment < ApplicationRecord
      cerializable serialize_with: SomeSerializerModule
    end

In these serializer modules, you can define methods and include other modules without polluting the corresponding models.

The only requirement is that the serializer modules have a `run` method which accepts two arguments and returns a hash detailing how instances of your model should be serialized.

Your model's `cerializable_hash` methods will use the `run` method of their serializers to produce their results.

Like `serializable_hash`, `cerializable_hash` accepts `:only`, `:except`, and `:methods` options which can be passed as a
symbol or as an array of symbols.

Using the `:only` option will return a hash that only has the specified keys:

    > comment.cerializable_hash(only: :id)
    => { id: 1 }

Using the `:except` option will return a hash that has all default keys except those specified:

    > comment.cerializable_hash(except: [:user_id, :ancestorCount, :childComments])
    => { id: 1, body: '...sushi? ' }

Using the `:methods` option add will add a key and value for each method specified.

The key is the method name and the value is the return value given when calling the method on the model instance.

The `:methods` option is processed after the `:only` and `:except` options:

    > comment.cerializable_hash(only: id, methods: :hash])
    => { id: 1, hash: -2535926706119161824 }

## Custom Serialization Options

You can pass in custom options that your serializer modules make use of.

Common use cases for custom options might be for handling roles or versions.

In the example serializer above, we're using a custom `:children` option.

This allows us to build a comment thread's hierarchy without querying for each comment's children:

    class CommentTreeService
      def self.call(comment_thread, options = { order: { ancestor_count: :asc, id: :desc } })
        self.new.for_thread(comment_thread, options)
      end

      def initialize
        @comments_hash = {}
        @result = []

        @children_resolver = proc do |parent_comment|
          children_array = []

          @comments_hash.each_pair do |id, comment|
            if comment.parent_type == 'Comment' && comment.parent_id == parent_comment.id
              @comments_hash.delete(id)
              children_array << comment.cerializable_hash(children: @children_resolver.call(comment))
            end
          end

          children_array
        end
      end

      def for_thread(comment_thread, options)
        comment_thread.comments
          .order(options[:order])
          .each { |comment| @comments_hash[comment.id] = comment }

        @comments_hash.each_pair do |id, comment|
          if comment.parent_type == 'CommentThread'
            @comments_hash.delete(id)
            @result << comment.cerializable_hash(children: @children_resolver.call(comment))
          end
        end

        @result
      end
    end
