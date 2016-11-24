module GetForXScraping
  extend ActiveSupport::Concern

  module ClassMethods
    def get_for_x_scraping(attribute, timelines, &block)
      column = :"#{attribute}_scraped_at"
      method_name = :"get_for_#{attribute}_scraping"

      where_query = [["( #{column} IS NULL )"] + timelines.map do |times|
        times = times.map(&:ago)

        if times.size == 1
          sanitize_sql_array(["( #{column} < ? )", times[0]])
        elsif times.size == 2
          sanitize_sql_array(["( released_at > ? AND #{column} < ? )", times[0], times[1]])
          # "( released_at > #{times[0]} AND #{column} < #{times[1]} )"
        end
      end].join(' OR ')

      define_singleton_method method_name do
        scope = order(:name).where(where_query)
        scope = scope.merge(block.call()) if block
        scope
      end
    end
  end
end
