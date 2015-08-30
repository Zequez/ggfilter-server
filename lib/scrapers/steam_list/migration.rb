module Scrapers
  module SteamList
    class Migration < ActiveRecord::Migration
      def change
        [
          [:steam_name, :string],
          [:steam_id, :integer],
          [:steam_price, :integer],
          [:steam_sale_price, :integer],
          [:steam_reviews_ratio, :integer],
          [:steam_reviews_count, :integer],
          [:steam_thumbnail, :string],
          [:released_at, :datetime]
        ].each do |(column, type)|
          add_column :games, column, type unless column_exists? :games, column
        end

        remove_column :games, :steam_sale if column_exists? :games, :steam_sale
        remove_column :games, :launch_date if column_exists? :games, :launch_date
        remove_column :games, :platforms if column_exists? :games, :platforms
        if column_exists? :games, :platforms
          change_column(:games, :platforms, :integer, default: 0, null: false)
        else
          add_column(:games, :platforms, :integer, default: 0, null: false)
        end
      end
    end
  end
end
