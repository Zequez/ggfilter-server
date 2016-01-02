class CreateGpus < ActiveRecord::Migration
  def change
    create_table :gpus do |t|
      t.timestamps null: false
    end
  end
end
