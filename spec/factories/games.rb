FactoryGirl.define do
  factory :game do
    sequence(:name){ |n| "GameName #{n}" }
  end
end
