FactoryGirl.define do
  factory :scrap_log do
    started_at Time.now
    finished_at Time.now + 3.minutes
    scraper "steam"
    error false
    msg "Some fancy data about the scraping"
  end
end
