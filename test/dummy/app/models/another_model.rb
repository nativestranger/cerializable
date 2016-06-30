class AnotherModel < ActiveRecord::Base
  # the :serialize_with option allows you to specify a serialization module
  acts_as_cerializable serialize_with: AnotherSerializer

  # this is here just to make testing easier
  def self.default_json_representation
    { arbitraryKey3: 'arbitrary value', arbitraryKey4: 'another arbitrary value' }
  end
end
