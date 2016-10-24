FactoryGirl.define do
  factory :steam_game do
    sequence(:name){ |n| "Game Name #{n}"}
    sequence(:steam_id){ |n| n + 10000 }
  end
end
