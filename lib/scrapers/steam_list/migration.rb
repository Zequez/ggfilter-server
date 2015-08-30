module Scrapers
  module SteamList
    class Migration < ActiveRecord::Migration
      def change
        [
          [:steam_name, :string],
          [:steam_id, :integer],
          [:steam_price, :integer],
          [:steam_sale, :integer], # deprecated
          [:steam_sale_price, :integer],
          [:steam_reviews_ratio, :integer],
          [:steam_reviews_count, :integer],
          [:steam_thumbnail, :string],
          [:launch_date, :datetime],
          [:platforms, :integer]
        ].each do |(column, type)|
          add_column :games, column, type unless column_exists? :games, column
        end
      end
    end
  end
end
