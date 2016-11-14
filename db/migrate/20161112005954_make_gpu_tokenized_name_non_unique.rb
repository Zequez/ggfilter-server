class MakeGpuTokenizedNameNonUnique < ActiveRecord::Migration[5.0]
  def change
    remove_index :gpus, :tokenized_name
    add_index :gpus, :tokenized_name, unique: false
  end
end
