appraise 'rails_5_devise_4' do
  # Until Mongoid 6 is released, allow Rails 5 dependencies to be installed,
  # see https://github.com/gonzalo-bulnes/simple_token_authentication/issues/231
  gem 'mongoid', git: 'https://github.com/mongodb/mongoid.git', branch: 'master'
end

appraise 'rails_4_devise_3' do
  gem 'actionmailer', '~> 4.0'
  gem 'actionpack', '~> 4.0'
  gem 'activerecord', '~> 4.0'
  gem 'devise', '~> 3.2'
end

appraise 'ruby_1.9.3_rails_3.2' do
  gem 'actionmailer', '>= 3.2.6', '< 4'
  gem 'actionpack', '>= 3.2.6', '< 4'
  gem 'activerecord', '>= 3.2.6', '< 4'
  gem 'mime-types', '< 3'
  gem 'tins', '< 1.7.0'
end
