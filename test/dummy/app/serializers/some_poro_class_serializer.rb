module SomePoroClassSerializer
  def run(model, options = {})
    result = SomePoroClass.default_json_representation
    options[:custom_option] ? result.merge(customOption: '( ͡° ͜ʖ ͡°)') : result
  end
end
