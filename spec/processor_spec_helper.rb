module ProcessorSpecHelper
  def scrap(page_url, add_to_queue = nil)
    response = Typhoeus.get(page_url)
    add_to_queue ||= lambda{|url|}
    processor_class.new(response, &add_to_queue).process_page
  end
end
