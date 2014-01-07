# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :private_post do
    title "Secret spaghetti recipe"
  end

  factory :invalid_private_post, class: :private_post do
    body "TODO"
  end
end
