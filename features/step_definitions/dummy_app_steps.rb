Given /^I have a dummy app$/ do
  raise "This step is deprecated, use 'I have a dummy app with a Devise-enabled User' instead."
end

Given /^I have a dummy app with a Devise-enabled (\w+)$/ do |model|
  # Caution: model should be a singular camel-cased name but could be pluralized or underscored.

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
    And a directory named "spec/support"
    And I write to "spec/support/factory_girl.rb" with:
      """
      require 'factory_girl_rails'
      """
    And a directory named "spec/factories"
    And I run `rails generate devise:install`
  }

  # See http://stackoverflow.com/a/10587853
  steps %Q{
    And I run `sed -i "1s/^/require 'devise';/" config/application.rb`
    And I write to "config/initializers/simple_token_authentication.rb" with:
      """
      require 'simple_token_authentication'
      """
  }

  # By adding Devise to a model, I implicitely create that model.
  steps %Q{
    And I run `rails generate devise #{model.camelize.singularize}`
  }

  # See https://github.com/gonzalo-bulnes/simple_token_authentication#installation
  steps %Q{
    And I run `rails g migration add_authentication_token_to_#{model.underscore.pluralize} authentication_token:string:index`
  }
end

Given /^I have a dummy app with a Devise-enabled (\w+) and (\w+)$/ do |first_model, second_model|
  # Caution: model should be a singular camel-cased name but could be pluralized or underscored.

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

  # By adding Devise to a model, I implicitely create that model.
  steps %Q{
    And I run `rails generate devise #{first_model.camelize.singularize}`
    And I run `rails generate devise #{second_model.camelize.singularize}`
  }

  # See https://github.com/gonzalo-bulnes/simple_token_authentication#installation
  steps %Q{
    And I run `rails g migration add_authentication_token_to_#{first_model.underscore.pluralize} authentication_token:string:index`
    And I run `rails g migration add_authentication_token_to_#{second_model.underscore.pluralize} authentication_token:string:index`
  }
end

Given /^a scaffolded (\w+)$/ do |model|
  # Caution: model should be a singular camel-cased name but could be pluralized or underscored.

  steps %Q{
    And I run `rails generate scaffold #{model.underscore.singularize} title:string body:text --test-framework rspec --fixture-replacement factory_girl`
  }
end

Given /^the `(\w+!?)` method always raises an exception$/ do |method_name|

  steps %Q{
    And I overwrite "app/controllers/application_controller.rb" with:
      """
      class ApplicationController < ActionController::Base
        # Prevent CSRF attacks by raising an exception.
        # For APIs, you may want to use :null_session instead.
        protect_from_forgery with: :exception

        # While `acts_as_token_authentication_handler` was not called,
        # neither should be `authenticate_user!`.
        # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8
        #
        # Yet once `acts_as_token_authentication_handler` was called, `authenticate_user!`
        # should also be called. Run `rspec` to ensure that's being true.
        # If called, the `authenticate_user!` method will raise an exception, that
        # allows both cases to be covered by their own spec example.
        #
        # See test/dummy/app/controllers/posts_controller.rb and
        # test/dummy/app/controllers/private_posts_controller.rb

        def #{method_name}
          raise "`#{method_name}` was called."
        end
      end
      """
  }
end

Given /^the `(\w+!?)` and `(\w+!?)` methods always raise an exception$/ do |first_method_name, second_method_name|
  steps %Q{
    And I overwrite "app/controllers/application_controller.rb" with:
      """
      class ApplicationController < ActionController::Base
        # Prevent CSRF attacks by raising an exception.
        # For APIs, you may want to use :null_session instead.
        protect_from_forgery with: :exception

        # While `acts_as_token_authentication_handler` was not called,
        # neither should be `authenticate_user!`.
        # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8
        #
        # Yet once `acts_as_token_authentication_handler` was called, `authenticate_user!`
        # should also be called. Run `rspec` to ensure that's being true.
        # If called, the `authenticate_user!` method will raise an exception, that
        # allows both cases to be covered by their own spec example.
        #
        # See test/dummy/app/controllers/posts_controller.rb and
        # test/dummy/app/controllers/private_posts_controller.rb

        def #{first_method_name}
          raise "`#{first_method_name}` was called."
        end

        def #{second_method_name} *args
          raise "`#{second_method_name}` was called."
        end
      end
      """
  }
end

Given /^the `sign_in` method always raises an exception to show its options$/ do
  steps %Q{
    And a directory named "lib/devise/controllers"
    And I write to "lib/devise/controllers/sign_in_out.rb" with:
      """
      module Devise
        module Controllers
          # Provide sign in and sign out functionality.
          # Included by default in all controllers.
          module SignInOut

            # Sign in a user that already was authenticated. This helper is useful for logging
            # users in after sign up.
            #
            def sign_in(resource_or_scope, *args)
              options = args.extract_options!
              raise "`sign_in` was called with options `#\{options.inspect\}`."
            end

          end
        end
      end
      """
  }
end

Given /^(\w+) `acts_as_token_authenticatable`$/ do |model|
  # Caution: model should be a singular camel-cased name but could be pluralized or underscored.

  steps %Q{
    And I overwrite "app/models/#{model.singularize.underscore}.rb" with:
      """
      class #{model.singularize.camelize} < ActiveRecord::Base
        # Include default devise modules. Others available are:
        # :confirmable, :lockable, :timeoutable and :omniauthable
        devise :database_authenticatable, :registerable,
               :recoverable, :rememberable, :trackable, :validatable

        acts_as_token_authenticatable
      end
      """
  }
end

Given /^PrivatePostsController `acts_as_token_authentication_handler`$/ do

  steps %Q{
    And I overwrite "app/controllers/private_posts_controller.rb" with:
      """
      class PrivatePostsController < ApplicationController

        # Please do notice that this controller DOES call `acts_as_authentication_handler`.
        # See test/dummy/spec/requests/posts_specs.rb
        acts_as_token_authentication_handler

        before_action :set_private_post, only: [:show, :edit, :update, :destroy]

        # GET /private_posts
        def index
          @private_posts = PrivatePost.all
        end

        # GET /private_posts/1
        def show
        end

        # GET /private_posts/new
        def new
          @private_post = PrivatePost.new
        end

        # GET /private_posts/1/edit
        def edit
        end

        # POST /private_posts
        def create
          @private_post = PrivatePost.new(private_post_params)

          if @private_post.save
            redirect_to @private_post, notice: 'Private post was successfully created.'
          else
            render action: 'new'
          end
        end

        # PATCH/PUT /private_posts/1
        def update
          if @private_post.update(private_post_params)
            redirect_to @private_post, notice: 'Private post was successfully updated.'
          else
            render action: 'edit'
          end
        end

        # DELETE /private_posts/1
        def destroy
          @private_post.destroy
          redirect_to private_posts_url, notice: 'Private post was successfully destroyed.'
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_private_post
            @private_post = PrivatePost.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def private_post_params
            params.require(:private_post).permit(:title, :body)
          end
      end
      """
  }
end

Given /^(\w+) `acts_as_token_authentication_handler_for` (\w+) with options:$/ do |controller, model, options|
  # Caution: model should be a singular camel-cased name but could be pluralized or underscored.
  # Caution: controller must be a camel cased name: e.g. CamelCasedController

  controller_back = controller
  controller = controller.gsub(/Controller/, '').singularize

  steps %Q{
    And I overwrite "app/controllers/#{controller_back.underscore}.rb" with:
      """
      class #{controller_back} < ApplicationController

        # Please do notice that this controller DOES call `acts_as_authentication_handler` with options.
        # See test/dummy/spec/requests/posts_specs.rb
        acts_as_token_authentication_handler_for #{model.singularize.camelize}, #{options}

        before_action :set_#{controller.underscore}, only: [:show, :edit, :update, :destroy]

        # GET /#{controller.underscore}
        def index
          @#{controller.pluralize.underscore} = #{controller}.all
        end

        # GET /#{controller.underscore}/1
        def show
        end

        # GET /#{controller.underscore}/new
        def new
          @#{controller.underscore} = #{controller}.new
        end

        # GET /#{controller.underscore}/1/edit
        def edit
        end

        # POST /#{controller.underscore}
        def create
          @#{controller.underscore} = #{controller}.new(#{controller.underscore}_params)

          if @#{controller.underscore}.save
            redirect_to @#{controller.underscore}, notice: '#{controller} was successfully created.'
          else
            render action: 'new'
          end
        end

        # PATCH/PUT /#{controller.underscore}/1
        def update
          if @#{controller.underscore}.update(#{controller.underscore}_params)
            redirect_to @#{controller.underscore}, notice: '#{controller} was successfully updated.'
          else
            render action: 'edit'
          end
        end

        # DELETE /#{controller.underscore}/1
        def destroy
          @#{controller.underscore}.destroy
          redirect_to #{controller.pluralize.underscore}_url, notice: '#{controller} was successfully destroyed.'
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_#{controller.underscore}
            @#{controller.underscore} = #{controller}.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def #{controller.underscore}_params
            params.require(:#{controller.underscore}).permit(:title, :body)
          end
      end
      """
  }
end

Given /^PrivatePostsController `acts_as_token_authentication_handler_for` (\w+)$/ do |model|
  # Caution: model should be a singular camel-cased name but could be pluralized or underscored.

  steps %Q{
    And I overwrite "app/controllers/private_posts_controller.rb" with:
      """
      class PrivatePostsController < ApplicationController

        # Please do notice that this controller DOES call `acts_as_authentication_handler`.
        # See test/dummy/spec/requests/posts_specs.rb
        acts_as_token_authentication_handler_for #{model.singularize.camelize}

        before_action :set_private_post, only: [:show, :edit, :update, :destroy]

        # GET /private_posts
        def index
          @private_posts = PrivatePost.all
        end

        # GET /private_posts/1
        def show
        end

        # GET /private_posts/new
        def new
          @private_post = PrivatePost.new
        end

        # GET /private_posts/1/edit
        def edit
        end

        # POST /private_posts
        def create
          @private_post = PrivatePost.new(private_post_params)

          if @private_post.save
            redirect_to @private_post, notice: 'Private post was successfully created.'
          else
            render action: 'new'
          end
        end

        # PATCH/PUT /private_posts/1
        def update
          if @private_post.update(private_post_params)
            redirect_to @private_post, notice: 'Private post was successfully updated.'
          else
            render action: 'edit'
          end
        end

        # DELETE /private_posts/1
        def destroy
          @private_post.destroy
          redirect_to private_posts_url, notice: 'Private post was successfully destroyed.'
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_private_post
            @private_post = PrivatePost.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def private_post_params
            params.require(:private_post).permit(:title, :body)
          end
      end
      """
  }
end

Given /^I silence the (\w+) spec errors$/ do |controller|
  puts """
  Errors should never pass silently.
  Unless explicitly silenced.
    -- PEP 20, The Zen of Python
  """

  steps %Q{
    And I overwrite "spec/controllers/#{controller.underscore}_spec.rb" with:
      """
      require 'spec_helper'

      describe #{controller} do

        # This should return the minimal set of attributes required to create a valid
        # #{controller}. As you add validations to #{controller}, be sure to
        # adjust the attributes here as well.
        let(:valid_attributes) { { "title" => "MyString" } }

        # This should return the minimal set of values that should be in the session
        # in order to pass any filters (e.g. authentication) defined in
        # #{controller}. Be sure to keep this updated too.
        let(:valid_session) { {} }

        describe "actions" do
          it "all require authentication" do
            # That's true for all actions, yet I think there's no need to repeat them all here.
            lambda { get :index, {}, valid_session }.should raise_exception(RuntimeError)
            lambda { get :new, {}, valid_session }.should raise_exception(RuntimeError)
          end
        end
      end
      """
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
