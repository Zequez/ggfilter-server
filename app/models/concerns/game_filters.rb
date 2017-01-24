module GameFilters
  # extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      include Filterable
      include FiltersDefinitions
      
      register_filter :name, :name_filter
      register_filter :tags, :tags_filter
      register_filter :steam_id, :exact_filter, column: [:steam_game, :steam_id]
      register_filter :steam_price, :range_filter, column: [:steam_game, :price]
      register_filter :metacritic, :range_filter, column: [:steam_game, :metacritic]
      register_filter :steam_reviews_count, :range_filter, column: [:steam_game, :reviews_count]
      register_filter :steam_reviews_ratio, :range_filter,
        column: [:steam_game, :reviews_ratio],
        select: ['steam_games.reviews_count AS steam_reviews_count']
      register_filter :released_at, :relative_date_range_filter, column: [:steam_game, :released_at]
      register_filter :released_at_absolute, :date_range_filter,
        column: [:steam_game, :released_at],
        as: :released_at
      register_filter :lowest_steam_price, :range_filter,
        joins: :steam_game,
        select: [:lowest_steam_price, 'steam_games.price AS steam_price']
      register_filter :steam_discount, :range_filter
      register_filter :steam_early_access, :exact_filter, column: [:steam_game, :early_access]

      register_filter :playtime_mean, :range_filter
      register_filter :playtime_median, :range_filter
      register_filter :playtime_rsd, :range_filter
      register_filter :playtime_mean_ftb, :range_filter
      register_filter :playtime_median_ftb, :range_filter

      register_filter :controller_support, :range_filter, column: [:steam_game, :controller_support]
      register_filter :platforms, :boolean_filter, column: [:steam_game, :platforms]
      register_filter :features, :boolean_filter, column: [:steam_game, :features]
      register_filter :players, :boolean_filter, column: [:steam_game, :players]
      register_filter :vr_platforms, :boolean_filter, column: [:steam_game, :vr_platforms]
      register_filter :vr_mode, :boolean_filter, column: [:steam_game, :vr_mode]
      register_filter :vr_controllers, :boolean_filter, column: [:steam_game, :vr_controllers]

      register_filter :sysreq_video_index, :range_filter
      register_filter :sysreq_index_centile, :range_filter
      # # register_filter :system_requirements,  :system_requirements_filter

      register_column :images, column: [:steam_game, :images]
      register_column :videos, column: [:steam_game, :videos]
      register_column :steam_thumbnail, column: [:steam_game, :thumbnail]
      register_column :sysreq_video_tokens_values
    end
  end
end
