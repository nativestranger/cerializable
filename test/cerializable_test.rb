require 'test_helper'

class CerializableTest < ActiveSupport::TestCase

  test "Cerializable is defined" do
    assert_kind_of Module, Cerializable
  end

  test "Cerializable#setup is defined" do
    assert true, Cerializable.respond_to?(:setup)
  end

  test "Cerializable::Cerializer is defined" do
    assert_kind_of Class, Cerializable::Cerializer
  end

  test "Cerializable::Model is defined" do
    assert_kind_of Module, Cerializable::Model
  end

end
