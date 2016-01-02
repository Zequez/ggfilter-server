class AddTokenizedNameToGpus < ActiveRecord::Migration
  def change
    add_column :gpus, :tokenized_name, :string
  end
end
