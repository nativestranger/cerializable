class SomePoroClass
  include Cerializable::Model
  acts_as_cerializable

  # this is here just to make testing easier
  def self.default_json_representation
    { arbitraryKey4: 'arbitrary value', arbitraryKey5: 'another arbitrary value' }
  end
end
