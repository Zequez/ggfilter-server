module GameFilters
  # extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      include Filterable
      include FiltersDefinitions

      register_filter :name, :name_filter
      register_filter :stores, :boolean_filter
      register_filter :released_at, :date_range_filter

      # IDs
      register_filter :steam_id, :exact_filter
      register_filter :oculus_id, :exact_filter

      # Prices
      register_filter :steam_price, :range_filter
      register_filter :steam_price_discount, :range_filter
      register_filter :oculus_price, :range_filter
      register_filter :oculus_price_discount, :range_filter
      register_filter :lowest_price, :range_filter
      register_filter :best_discount, :range_filter

      # Ratings
      register_filter :ratings_count, :range_filter
      register_filter :ratings_ratio, :range_filter
      register_filter :ratings_pct, :range_filter
      register_filter :metacritic, :range_filter

      # Tags
      register_filter :tags, :tags_filter

      # Playtime
      register_filter :playtime_mean, :range_filter
      register_filter :playtime_median, :range_filter
      register_filter :playtime_rsd, :range_filter
      register_filter :playtime_mean_ftb, :range_filter
      register_filter :playtime_median_ftb, :range_filter

      # Other
      # register_filter :steam_early_access, :exact_filter
      # register_filter :vr_only, :exact_filter
      register_filter :sysreq_index, :range_filter

      # Flags
      # register_filter :steam_features, :boolean_filter

      # register_filter :gamepad, :boolean_filter
      register_filter :platforms, :boolean_filter
      register_filter :players, :boolean_filter
      register_filter :vr_platforms, :boolean_filter
      register_filter :vr_modes, :boolean_filter
      register_filter :controllers, :boolean_filter

      # Percentiles
      register_filter :sysreq_index_pct, :range_filter

      # Columns-only
      register_column :images
      # register_column :videos
      register_column :thumbnail
      register_column :urls
      register_column :prices
    end
  end
end
