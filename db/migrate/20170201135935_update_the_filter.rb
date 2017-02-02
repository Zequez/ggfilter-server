class UpdateTheFilter < ActiveRecord::Migration[5.0]
  def change
    rename_column :filters, :user_slug, :name_slug
    rename_column :filters, :official_slug, :global_slug
    remove_column :filters, :filter

    add_column :filters, :controls, :text, default: '{}', null: false
    add_column :filters, :columns, :text, default: '{}', null: false
    add_column :filters, :sorting, :text, default: '{}', null: false
    add_column :filters, :secret, :string
    add_column :filters, :front_page, :integer
  end
end
