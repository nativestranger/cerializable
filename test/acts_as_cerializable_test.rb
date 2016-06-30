require 'test_helper'

class ActsAsCerializableTest < ActiveSupport::TestCase

  test "ActiveRecord::Base#acts_as_cerializable" do
    assert true, ActiveRecord::Base.respond_to?(:acts_as_cerializable)
  end

  # Ensure both models are serializing their instances as expected
  [Model, AnotherModel].each { |model_class|

    test "#{ model_class.name }#serializer is defined" do
      assert_equal model_class.send(:serializer).class, Cerializable::Cerializer
      assert true, model_class.send(:serializer).respond_to?(:run)
    end

    expected_result = model_class.send(:default_json_representation)
    [:serializable_hash, :as_json, :to_json].each do |method_name|

      test "#{ model_class.name.downcase }##{ method_name } works as expected" do
        instance = model_class.send(:new)

        assert_equal instance.send(method_name), expected_result

        # except option
        assert_equal instance.send(method_name, except: :arbitraryKey1), expected_result.except(:arbitraryKey1)

        assert_equal instance.send(method_name, except: [:arbitraryKey1, :arbitraryKey2]),
                     expected_result.except(:arbitraryKey1, :arbitraryKey2)

        # only option
        assert_equal instance.send(method_name, only: :arbitraryKey1), expected_result.slice(:arbitraryKey1)

        assert_equal instance.send(method_name, only: [:arbitraryKey1, :arbitraryKey2]),
                     expected_result.slice(:arbitraryKey1, :arbitraryKey2)

        # method option
        assert_equal instance.send(method_name, methods: :object_id),
                     expected_result.merge(object_id: instance.object_id)

        assert_equal instance.send(method_name, methods: [:object_id, :hash]),
                     expected_result.merge(object_id: instance.object_id, hash: instance.hash)

        # custom option
        assert_equal instance.send(method_name, custom_option: true),
                     expected_result.merge(customOption: '( ͡° ͜ʖ ͡°)')
      end
    end

  }

end
