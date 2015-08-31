module SteamListTestHelpers
  def steam_list_url(page_or_query, page = nil)
    query = nil
    if page_or_query.kind_of?(String)
      query = CGI.escape(page_or_query)
    else
      page ||= page_or_query
    end

    query = "term=#{query}&sort_by=_ASC" if query
    page = "page=#{page}" if page

    "http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&#{page}&#{query}"
  end
end
