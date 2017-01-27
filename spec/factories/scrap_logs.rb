FactoryGirl.define do
  factory :scrap_log do
    started_at Time.now
    scraper_finished_at Time.now + 2.minutes
    finished_at Time.now + 3.minutes
    task_name 'fancy_task'
    error false
    msg "Some fancy data about the scraping"
  end
end
