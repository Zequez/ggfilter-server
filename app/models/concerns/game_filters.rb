module GameFilters
  # extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      include Filterable
      include FiltersDefinitions

      register_filter :name, :name_filter
      register_filter :stores, :boolean_filter
      register_filter :released_at, :relative_date_range_filter
      register_filter :released_at_absolute, :date_range_filter, as: :released_at

      # IDs
      register_filter :steam_id, :exact_filter, column: [:steam_game, :steam_id]
      register_filter :oculus_id, :exact_filter, column: [:oculus_game, :oculus_id]

      # Prices
      register_filter :steam_price, :range_filter,
        select: [:steam_price, :steam_price_regular]
      register_filter :steam_price_discount, :range_filter
      register_filter :oculus_price, :range_filter,
        select: [:oculus_price, :oculus_price_regular]
      register_filter :oculus_price_discount, :range_filter
      register_filter :lowest_price,
        select: [
          :lowest_price,
          :oculus_price,
          :oculus_price_regular,
          :oculus_price_discount,
          :steam_price,
          :steam_price_regular,
          :steam_price_discount
        ]

      # Ratings
      register_filter :ratings_count, :range_filter
      register_filter :ratings_ratio, :range_filter,
        select: [:ratings_ratio, :ratings_count]
      register_filter :metacritic, :range_filter, column: [:steam_game, :metacritic]

      # Tags
      register_filter :tags, :tags_filter

      # Playtime
      register_filter :playtime_mean, :range_filter
      register_filter :playtime_median, :range_filter
      register_filter :playtime_rsd, :range_filter
      register_filter :playtime_mean_ftb, :range_filter
      register_filter :playtime_median_ftb, :range_filter

      # Other
      register_filter :steam_early_access, :exact_filter, column: [:steam_game, :early_access]
      register_filter :vr_only, :exact_filter
      register_filter :sysreq_index, :range_filter

      # Flags
      register_filter :steam_features, :boolean_filter, column: [:steam_game, :features]

      register_filter :controller_support, :boolean_filter
      register_filter :platforms, :boolean_filter
      register_filter :players, :boolean_filter
      register_filter :vr_platforms, :boolean_filter
      register_filter :vr_mode, :boolean_filter
      register_filter :controllers, :boolean_filter

      # Percentiles
      register_filter :sysreq_index_pct, :range_filter

      register_column :images
      register_column :videos
      register_column :thumbnail
    end
  end
end
