module ProcessorSpecHelper
  def scrap(page_url, headers = {}, &add_to_queue)
    response = Typhoeus.get(page_url, headers: headers)
    add_to_queue ||= lambda{|url|}
    processor_class.new(response, &add_to_queue).process_page
  end
end
