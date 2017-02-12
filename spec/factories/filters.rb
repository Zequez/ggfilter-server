FactoryGirl.define do
  factory :filter do
    sequence(:ip_address){ |n| "127.0.0.#{n}" }
  end

  factory :filter_for_create, class: Filter do
    controls_list([])
    controls_hl_mod([])
    controls_params({})
    columns_list([])
    columns_params({})
    sorting({})
    global_config({})
  end
end
