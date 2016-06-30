module ModelSerializer
  def run(model, options = {})
    result = Model.default_json_representation
    options[:custom_option] ? result.merge(customOption: '( ͡° ͜ʖ ͡°)') : result
  end
end
