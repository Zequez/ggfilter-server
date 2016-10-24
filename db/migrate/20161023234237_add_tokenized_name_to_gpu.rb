class AddTokenizedNameToGpu < ActiveRecord::Migration[5.0]
  def change
    add_column :gpus, :tokenized_name, :string
    add_index :gpus, :tokenized_name, unique: true
  end
end
