class AddOfficialSlugToFilter < ActiveRecord::Migration
  def change
    rename_column :filters, :slug, :user_slug
    add_column :filters, :official_slug, :string, null: true
    add_index :filters, :official_slug, unique: true
    remove_index :filters, :sid
    add_index :filters, :sid, unique: true
  end
end
