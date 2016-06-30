class CreateAnotherModels < ActiveRecord::Migration
  def change
    create_table :another_models do |t|

      t.timestamps null: false
    end
  end
end
