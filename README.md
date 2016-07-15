Simple Token Authentication
===========================

[![Gem Version](https://badge.fury.io/rb/simple_token_authentication.svg)](http://badge.fury.io/rb/simple_token_authentication)
[![Build Status](https://travis-ci.org/gonzalo-bulnes/simple_token_authentication.svg?branch=master)](https://travis-ci.org/gonzalo-bulnes/simple_token_authentication)
[![Code Climate](https://codeclimate.com/github/gonzalo-bulnes/simple_token_authentication.svg)](https://codeclimate.com/github/gonzalo-bulnes/simple_token_authentication)
[![Dependency Status](https://gemnasium.com/gonzalo-bulnes/simple_token_authentication.svg)](https://gemnasium.com/gonzalo-bulnes/simple_token_authentication)
[![security](https://hakiri.io/github/gonzalo-bulnes/simple_token_authentication/master.svg)](https://hakiri.io/github/gonzalo-bulnes/simple_token_authentication/master)
[![Inline docs](http://inch-ci.org/github/gonzalo-bulnes/simple_token_authentication.svg?branch=master)](http://inch-ci.org/github/gonzalo-bulnes/simple_token_authentication)

Token authentication support has been removed from [Devise][devise] for security reasons. In [this gist][original-gist], Devise's [José Valim][josevalim] explains how token authentication should be performed in order to remain safe.

This gem packages the content of the gist and provides a set of convenient options for increased flexibility.

  [devise]: https://github.com/plataformatec/devise
  [original-gist]: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6


> **DISCLAIMER**: I am not José Valim, nor has he been involved in the gem bundling process. Implementation errors, if any, are mine; and contributions are welcome. -- [GB][gonzalo-bulnes]

  [josevalim]: https://github.com/josevalim
  [gonzalo-bulnes]: https://github.com/gonzalo-bulnes

Installation
------------

### In a nutshell

First install [Devise][devise] and configure it with any modules you want, then add the gem to your `Gemfile` and `bundle install`:

```ruby
# Gemfile

gem 'simple_token_authentication', '~> 1.0' # see semver.org
```

Once that done, only two steps are required to setup token authentication:

1. [Make one or more models token authenticatable][token_authenticatable] (ActiveRecord and Mongoid are supported)
1. [Allow controllers to handle token authentication][token_authentication_handler] (Rails, Rails API, and `ActionController::Metal` are supported)

_If you want more details about how the gem works, keep reading! We'll get to these two steps after the overview._

  [token_authenticatable]: #make-models-token-authenticatable
  [token_authentication_handler]: #allow-controllers-to-handle-token-authentication

### Overview

Simple Token Authentication provides the ability to manage an `authentication_token` from your model instances. A model with that ability enabled is said to be **token authenticatable** (typically, the `User` model will be made token authenticatable).

The gem also provides the ability for any controller to handle token authentication for one or multiple _token authenticatable_ models. That ability allows, for example, to automatically sign in an `user` when the correct credentials are provided with a request. A controller with that ability enabled is said to behave as a **token authentication handler**.
The token authentication credentials for a given request can be provided either in the form of [query params][authentication_method_query_params], or [HTTP headers][authentication_method_headers]. By default, the required credentials are the user's email and their authentication token.

What happens when a request is provided with no credentials or incorrect credentials is [highly configurable][integration_with_other_authentication_methods] (some scenarios may require access to be denied, other may allow unauthenticated access, or provide others strategies to authenticate users). By default, when token authentication fails, Devise is used as a fallback to ensure a consistent behaviour with controllers that do not handle token authentication.

  [authentication_method_query_params]: #authentication-method-1-query-params
  [authentication_method_headers]: #authentication-method-2-request-headers
  [integration_with_other_authentication_methods]: #integration-with-other-authentication-and-authorization-methods

### Make models token authenticatable

#### ActiveRecord

First define which model or models will be token authenticatable (typ. `User`):

```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  acts_as_token_authenticatable

  # Note: you can include any module you want. If available,
  # token authentication will be performed before any other
  # Devise authentication method.
  #
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  # ...
end
```

If the model or models you chose have no `:authentication_token` attribute, add them one (with a unique index):

```bash
rails g migration add_authentication_token_to_users "authentication_token:string{30}:uniq"
rake db:migrate
```

#### Mongoid

Define which model or models will be token authenticatable (typ. `User`):

```ruby
# app/models/user.rb

class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Token Authenticatable
  acts_as_token_authenticatable
  field :authentication_token

  # ...
end
```

### Allow controllers to handle token authentication

Finally define which controllers will handle token authentication (typ. `ApplicationController`) for which _token authenticatable_ models:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base # or ActionController::API
                                                     # or ActionController::Metal
  # ...

  acts_as_token_authentication_handler_for User

  # Security note: controllers with no-CSRF protection must disable the Devise fallback,
  # see #49 for details.
  # acts_as_token_authentication_handler_for User, fallback: :none

  # The token authentication requirement can target specific controller actions:
  # acts_as_token_authentication_handler_for User, only: [:create, :update, :destroy]
  # acts_as_token_authentication_handler_for User, except: [:index, :show]
  #
  # Or target specific controller conditions:
  # acts_as_token_authentication_handler_for User, unless: lambda { |controller| controller.request.format.html? }
  # acts_as_token_authentication_handler_for User, if: lambda { |controller| controller.request.format.json? }

  # Several token authenticatable models can be handled by the same controller.
  # If so, for all of them except the last, the fallback should be set to :none.
  #
  # Please do notice that the order of declaration defines the order of precedence.
  #
  # acts_as_token_authentication_handler_for Admin, fallback: :none
  # acts_as_token_authentication_handler_for SpecialUser, fallback: :none
  # acts_as_token_authentication_handler_for User # the last fallback is up to you

  # Aliases can be defined for namespaced models:
  #
  # acts_as_token_authentication_handler_for Customer::Representative, as: :facilitator
  # acts_as_token_authentication_handler_for SpecialUser, as: :user
  #
  # When defined, aliases are used to define both the params and the header names to watch.
  # E.g. facilitator_token, X-Facilitator-Token

  # ...
end
```

Configuration
-------------

Some aspects of the behavior of _Simple Token Authentication_ can be customized with an initializer.

The file below contains examples of the patterns that _token authentication handlers_ will watch for credentials (e.g. `user_email`, `X-SuperAdmin-Token`) and how to customize them:

```ruby
# config/initializers/simple_token_authentication.rb

SimpleTokenAuthentication.configure do |config|

  # Configure the session persistence policy after a successful sign in,
  # in other words, if the authentication token acts as a signin token.
  # If true, user is stored in the session and the authentication token and
  # email may be provided only once.
  # If false, users must provide their authentication token and email at every request.
  # config.sign_in_token = false

  # Configure the name of the HTTP headers watched for authentication.
  #
  # Default header names for a given token authenticatable entity follow the pattern:
  #   { entity: { authentication_token: 'X-Entity-Token', email: 'X-Entity-Email'} }
  #
  # When several token authenticatable models are defined, custom header names
  # can be specified for none, any, or all of them.
  #
  # Note: when using the identifiers options, this option behaviour is modified.
  # Please see the example below.
  #
  # Examples
  #
  #   Given User and SuperAdmin are token authenticatable,
  #   When the following configuration is used:
  #     `config.header_names = { super_admin: { authentication_token: 'X-Admin-Auth-Token' } }`
  #   Then the token authentification handler for User watches the following headers:
  #     `X-User-Token, X-User-Email`
  #   And the token authentification handler for SuperAdmin watches the following headers:
  #     `X-Admin-Auth-Token, X-SuperAdmin-Email`
  #
  #   When the identifiers option is set:
  #     `config.identifiers = { super_admin: :phone_number }`
  #   Then both the header names identifier key and default value are modified accordingly:
  #     `config.header_names = { super_admin: { phone_number: 'X-SuperAdmin-PhoneNumber' } }`
  #
  # config.header_names = { user: { authentication_token: 'X-User-Token', email: 'X-User-Email' } }

  # Configure the name of the attribute used to identify the user for authentication.
  # That attribute must exist in your model.
  #
  # The default identifiers follow the pattern:
  # { entity: 'email' }
  #
  # Note: the identifer must match your Devise configuration,
  # see https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address#tell-devise-to-use-username-in-the-authentication_keys
  #
  # Note: setting this option does modify the header_names behaviour,
  # see the header_names section above.
  #
  # Example:
  #
  #   `config.identifiers = { super_admin: 'phone_number', user: 'uuid' }`
  #
  # config.identifiers = { user: 'email' }

  # Configure the Devise trackable strategy integration.
  #
  # If true, tracking is disabled for token authentication: signing in through
  # token authentication won't modify the Devise trackable statistics.
  #
  # If false, given Devise trackable is configured for the relevant model,
  # then signing in through token authentication will be tracked as any other sign in.
  #
  # config.skip_devise_trackable = true
end
```

Usage
-----

### Tokens Generation

Assuming `user` is an instance of `User`, which is _token authenticatable_: each time `user` will be saved, and `user.authentication_token.blank?` it receives a new and unique authentication token (via `Devise.friendly_token`).

### Authentication Method 1: Query Params

You can authenticate passing the `user_email` and `user_token` params as query params:

```
GET https://secure.example.com?user_email=alice@example.com&user_token=1G8_s7P-V-4MGojaKD7a
```

The _token authentication handler_ (e.g. `ApplicationController`) will perform the user sign in if both are correct.

### Authentication Method 2: Request Headers

You can also use request headers (which may be simpler when authenticating against an API):

```
X-User-Email alice@example.com
X-User-Token 1G8_s7P-V-4MGojaKD7a
```

In fact, you can mix both methods and provide the `user_email` with one and the `user_token` with the other, even if it would be a freak thing to do.

### Integration with other authentication and authorization methods

If sign-in is successful, no other authentication method will be run, but if it doesn't (the authentication params were missing, or incorrect) then Devise takes control and tries to `authenticate_user!` with its own modules. That behaviour can however be modified for any controller through the **fallback** option (which defaults to `fallback: :devise`).

When `fallback: :exception` is set, then an exception is raised on token authentication failure. The resulting controller behaviour is very similar to the behaviour induced by using the Devise `authenticate_user!` callback instead of `authenticate_user`. That setting allows, for example, to prevent unauthenticated users to accede API controllers while disabling the default fallback to Devise.

**Important**: Please do notice that controller actions without CSRF protection **must** disable the Devise fallback for [security reasons][csrf] (both `fallback: :exception` and `fallback: :none` will disable the Devise fallback). Since Rails enables CSRF protection by default, this configuration requirement should only affect controllers where you have disabled it specifically, which may be the case of API controllers.

To use no fallback when token authentication fails, set `fallback: :none`.

  [csrf]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues/49

### Hooks

One hook is currently available to trigger custom behaviour after an user has been successfully authenticated through token authentication. To use it, override the `after_successful_token_authentication` method in the corresponding token authentication handler:

```ruby
# app/controller/application_controller.rb

class ApplicationController < ActiveController::Base
  acts_as_token_authentication_handler_for User

  # ...

  private

    def after_successful_token_authentication
      # Make the authentication token to be disposable - for example
      renew_authentication_token!
    end
end
```

### Testing

Here is an example of how you can test-drive your configuration using [Minitest][minitest]:

  [minitest]: https://github.com/seattlerb/minitest

```ruby
class SomeControllerTest < ActionController::TestCase

  test "index with token authentication via query params" do
    get :index, { user_email: "alice@example.com", user_token: "1G8_s7P-V-4MGojaKD7a" }
    assert_response :success
  end

  test "index with token authentication via request headers" do
    @request.headers['X-User-Email'] = "alice@example.com"
    @request.headers['X-User-Token'] = "1G8_s7P-V-4MGojaKD7a"

    get :index
    assert_response :success
  end
end
```

Documentation
-------------

### Frequently Asked Questions

Any question? Please don't hesitate to open a new issue to get help. I keep questions tagged to make possible to [review the open questions][open-questions], while closed questions are organized as a sort of [FAQ][faq].

  [open-questions]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues?labels=question&page=1&state=open
  [faq]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues?direction=desc&labels=question&page=1&sort=comments&state=closed

### Change Log

Releases are commented to provide a [brief change log][releases], details can be found in the [`CHANGELOG`][changelog] file.

  [releases]: https://github.com/gonzalo-bulnes/simple_token_authentication/releases
  [changelog]: ./CHANGELOG.md

Development
-----------

### Testing and documentation

This gem development has been test-driven since `v1.0.0`. Until `v1.5.1`, the gem behaviour was described using [Cucumber][cucumber] and [RSpec][rspec] in a dummy app generated by [Aruba][aruba]. Since `v1.5.2` it is described using Rspec alone and [Appraisal][appraisal] is used since `v1.13.0` for [regression testing][regression].

RSpec [tags][tags] are used to categorize the spec examples.

Spec examples that are tagged as `public` describe aspects of the gem public API, and MAY be considered as the gem documentation.

The `private` or `protected` specs are written for development purpose only. Because they describe internal behaviour which may change at any moment without notice, they are only executed as a secondary task by the [continuous integration service][travis] and SHOULD be ignored.

Run `rake spec:public` to print the gem public documentation.

  [appraisal]: https://github.com/thoughtbot/appraisal
  [aruba]: https://github.com/cucumber/aruba
  [cucumber]: https://github.com/cucumber/cucumber-rails
  [regression]: https://github.com/gonzalo-bulnes/simple_token_authentication/wiki/Regression-Testing
  [rspec]: https://www.relishapp.com/rspec/rspec-rails/docs
  [tags]: https://www.relishapp.com/rspec/rspec-core/v/3-1/docs/command-line/tag-option
  [travis]: https://travis-ci.org/gonzalo-bulnes/simple_token_authentication/builds

### Contributions

Contributions are welcome! I'm not personally maintaining any [list of contributors][contributors] for now, but any PR which references us all will be welcome.

  [contributors]: https://github.com/gonzalo-bulnes/simple_token_authentication/graphs/contributors

Please be sure to [review the open issues][open-questions] and contribute with your ideas or code in the issue best suited to the topic. Keeping discussions in a single place makes easier to everyone interested in that topic to keep track of the contributions.

Finally, please note that this project is released with a [Contributor Code of Conduct][coc]. By participating in this project you agree to abide by its terms.

  [coc]: ./CODE_OF_CONDUCT.md

Credits
-------

It may sound a bit redundant, but this gem wouldn't exist without [this gist][original-gist], nor without the [comments][issues] and [contributions][pulls] of many people. Thank them if you see them!

  [issues]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues
  [pulls]: https://github.com/gonzalo-bulnes/simple_token_authentication/pulls

License
-------

    Simple Token Authentication
    Copyright (C) 2013, 2014, 2015, 2016 Gonzalo Bulnes Guilpain

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
