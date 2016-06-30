class Model < ActiveRecord::Base
  # by default, Cerializable#setup will look for a module named "#{ model_name }Serializer"
  acts_as_cerializable

  # this is here just to make testing easier
  def self.default_json_representation
    { arbitraryKey1: 'value', arbitraryKey2: 'another value' }
  end
end
