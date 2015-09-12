module Scrapers
  module SteamList
    class Migration < ActiveRecord::Migration

      class Migration2 < ActiveRecord::Migration
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
            add_column :games, column, type
          end

          add_column(:games, :platforms, :integer, default: 0, null: false)
        end
      end

    end
  end
end
