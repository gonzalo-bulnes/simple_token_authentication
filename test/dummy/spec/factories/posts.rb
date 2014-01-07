# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    title "Gems testing with RSpec and Cucumber"
  end

  factory :invalid_post, class: :post do
  end
end
