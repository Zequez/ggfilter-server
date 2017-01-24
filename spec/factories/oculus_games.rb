FactoryGirl.define do
  factory :oculus_game do
    sequence(:oculus_id){ |n| n + 10000 }
    sequence(:name){ |n| "Game Name #{n}"}
    price 999
    price_regular nil
    released_at 6.months.ago
    summary 'This is a summary'
    version '1.1.0'
    category 'Action'
    genres ['Potato', 'Galaxy']
    languages ['English', 'Potato Language']
    age_rating nil
    developer 'PotatoDev'
    publisher 'PotatoStudio'
    vr_mode ['STANDING']
    vr_tracking ['FRONT_FACING']
    vr_controllers ['OCULUS_TOUCH']
    players ['SINGLE_USER']
    comfort 'COMFORTABLE_FOR_MOST'
    internet 'NOT_REQUIRED'
    sysreq_hdd 123456789
    sysreq_cpu 'Intel Galaxy i5'
    sysreq_gpu 'Nvidia Fire Universe 9999'
    sysreq_ram 8
    website_url 'http://www.example.com'
    rating_1 10
    rating_2 20
    rating_3 30
    rating_4 40
    rating_5 50
    thumbnail 'http://www.example.com'
    screenshots ['http://example.com']
    trailer_video 'http://www.example.com'
    trailer_thumbnail 'http://www.example.com'
  end
end
