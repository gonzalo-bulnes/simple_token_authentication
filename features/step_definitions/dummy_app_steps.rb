Given /^I have a dummy app$/ do
  steps %Q{
    Given I cd to "../.."
    And a directory named "spec/dummy"
    And I cd to "spec"
    And I run `rm -r dummy`
    And a directory named "dummy"
    And I cd to "dummy"
    And I run `rvm current`
    And I run `pwd`
    And The default aruba timeout is 30 seconds
    And I run `rails new . --skip-bundle --skip-test-unit --skip-javascript`
    And I append to "Gemfile" with:
      """

      # SimpleTokenAuthentication

      gem 'simple_token_authentication', path: '../../'

      group :development, :test do
        gem 'rspec-rails', require: false
        gem 'factory_girl_rails', require: false
      end
      """
    And I run `bundle install`
    And I run `rails generate rspec:install`
    And I append to ".rspec" with:
      """
      --format documentation
      """
    And I run `rails generate devise:install`
  }

  # See http://stackoverflow.com/a/10587853
  steps %Q{
    And I run `sed -i "1s/^/require 'devise';/" config/initializers/devise.rb`
    And I write to "config/initializers/simple_token_authentication.rb" with:
      """
      require 'simple_token_authentication'
      """
  }

  # By adding Devise to User, I implicitely add a User model. That's necessary
  # because SimpleTokenAuthentication depends on it.
  # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/2
  steps %Q{
    And I run `rails generate devise User`
  }

  # See https://github.com/gonzalo-bulnes/simple_token_authentication#installation
  steps %Q{
    And I run `rails g migration add_authentication_token_to_users authentication_token:string:index`
  }
end

Given /^I prepare the test database$/ do
  steps %{
    And I set the environment variables to:
      | RAILS_ENV | test |
    And I run `bundle exec rake db:drop`
    And I run `bundle exec rake db:create`
    And I run `bundle exec rake db:migrate`
  }
end
