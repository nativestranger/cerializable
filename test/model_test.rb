require 'test_helper'

class ModelTest < ActiveSupport::TestCase

  test "ActiveRecord::Base#acts_as_cerializable" do
    assert true, ActiveRecord::Base.respond_to?(:acts_as_cerializable)
  end

  test "ActiveRecord::Base#cerializable" do
    assert true, ActiveRecord::Base.respond_to?(:cerializable)
  end

  # Ensure both models are serializing their instances as expected
  [Model, AnotherModel, SomePoroClass].each { |model_class|

    test "#{ model_class.name }#cerializer is defined" do
      assert_equal model_class.send(:cerializer).class, Cerializable::Cerializer
      assert true, model_class.send(:cerializer).respond_to?(:run)
    end

    expected_result = model_class.send(:default_json_representation)

    test "#{ model_class.name.downcase }cerializable_hash works as expected" do
      instance = model_class.new

      assert_equal instance.cerializable_hash, expected_result

      # except option
      assert_equal instance.cerializable_hash(except: :arbitraryKey1), expected_result.except(:arbitraryKey1)

      assert_equal instance.cerializable_hash(except: [:arbitraryKey1, :arbitraryKey2]),
                   expected_result.except(:arbitraryKey1, :arbitraryKey2)

      # only option
      assert_equal instance.cerializable_hash(only: :arbitraryKey1), expected_result.slice(:arbitraryKey1)

      assert_equal instance.cerializable_hash(only: [:arbitraryKey1, :arbitraryKey2]),
                   expected_result.slice(:arbitraryKey1, :arbitraryKey2)

      # method option
      assert_equal instance.cerializable_hash(methods: :object_id),
                   expected_result.merge(object_id: instance.object_id)

      assert_equal instance.cerializable_hash(methods: [:object_id, :hash]),
                   expected_result.merge(object_id: instance.object_id, hash: instance.hash)

      # custom option
      assert_equal instance.cerializable_hash(custom_option: true),
                   expected_result.merge(customOption: '( ͡° ͜ʖ ͡°)')
    end

  }

end
