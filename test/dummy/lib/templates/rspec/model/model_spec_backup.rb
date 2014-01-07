Feature: attributes

  Scenario: listing attributes
    #Given I run `cd example`
    #Given I run `rails g model widget name:string priority:integer`
    #Given I run `/bin/bash --login -c "rvm use ruby-1.9.3-head@custom-rails-generators-example && rvm current && bundle install --gemfile=example/Gemfile"`
    # And I run `rvm current`
    # And I run `bundle install`
    When I run `rspec`
    #When I run `/bin/bash --login -c "rvm use ruby-1.9.3-head@custom-rails-generators-example && rvm current && bundle exec rspec"`

    # Given I run `rvm use ruby-1.9.3-head@custom-rails-generators-example`
    # And I run `bundle install`
    #Given I run `rails g model widget name:string priority:integer`
    #When I run `/bin/bash --login -c "rvm use 1.9.3-head@custom-rails-generators-example && rvm current && bundle install"`
    #And I run `rvm current`
    Then the examples should all pass
    # And the output contains 'responds to name'
    # And the ouput contains 'responds to priority'
