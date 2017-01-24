class AddOculusGame < ActiveRecord::Migration[5.0]
  def change
    create_table :oculus_games do |t|
      # Game data
      t.integer :oculus_id, null: false
      t.string :name, null: false
      t.integer :price, null: false
      t.integer :price_was
      t.text :summary
      t.string :version
      t.string :category
      t.string :genres, default: '[]', null: false
      t.string :languages, default: '[]', null: false
      t.string :age_rating
      t.string :developer
      t.string :publisher

      # Flags
      t.integer :vr_mode, default: 0, null: false
      t.integer :vr_tracking, default: 0, null: false
      t.integer :vr_controllers, default: 0, null: false
      t.integer :players, default: 0, null: false

      # Enums
      t.integer :comfort, default: 0, null: false
      t.integer :internet, default: 0, null: false

      t.boolean :win10_required, default: false, null: false

      # System requirements
      t.string :sysreq_hdd
      t.string :sysreq_cpu
      t.string :sysreq_gpu
      t.string :sysreq_ram

      # Urls
      t.string :website_url

      # Ratings
      t.integer :rating_1, default: 0, null: false
      t.integer :rating_2, default: 0, null: false
      t.integer :rating_3, default: 0, null: false
      t.integer :rating_4, default: 0, null: false
      t.integer :rating_5, default: 0, null: false

      t.string :thumbnail
      t.text :screenshots, default: '[]', null: false
      t.string :trailer_video
      t.string :trailer_thumbnail
    end

    add_index :oculus_games, :oculus_id, unique: true
    add_index :oculus_games, :name, unique: true
  end
end
