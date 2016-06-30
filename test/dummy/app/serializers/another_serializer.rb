module AnotherSerializer
  def run(model, options = {})
    result = AnotherModel.default_json_representation
    options[:custom_option] ? result.merge(customOption: '( ͡° ͜ʖ ͡°)') : result
  end
end
