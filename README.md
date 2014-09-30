Simple Token Authentication
===========================

[![Gem Version](https://badge.fury.io/rb/simple_token_authentication.png)](http://badge.fury.io/rb/simple_token_authentication)
[![Build Status](https://travis-ci.org/gonzalo-bulnes/simple_token_authentication.png?branch=master)](https://travis-ci.org/gonzalo-bulnes/simple_token_authentication)
[![Code Climate](https://codeclimate.com/github/gonzalo-bulnes/simple_token_authentication.png)](https://codeclimate.com/github/gonzalo-bulnes/simple_token_authentication)
[![Dependency Status](https://gemnasium.com/gonzalo-bulnes/simple_token_authentication.svg)](https://gemnasium.com/gonzalo-bulnes/simple_token_authentication)
[![Inline docs](http://inch-ci.org/github/gonzalo-bulnes/simple_token_authentication.svg?branch=master)](http://inch-ci.org/github/gonzalo-bulnes/simple_token_authentication)

Token authentication support has been removed from [Devise][devise] for security reasons. In [this gist][original-gist], Devise's [José Valim][josevalim] explains how token authentication should be performed in order to remain safe.

This gem packages the content of the gist.

  [devise]: https://github.com/plataformatec/devise
  [original-gist]: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6


> **DISCLAIMER**: I am not José Valim, nor has he been involved in the gem bundling process. Implementation errors, if any, are mine; and contributions are welcome. -- [GB][gonzalo-bulnes]

  [josevalim]: https://github.com/josevalim
  [gonzalo-bulnes]: https://github.com/gonzalo-bulnes

Installation
------------

Install [Devise][devise] with any modules you want, then add the gem to your `Gemfile`:

```ruby
# Gemfile

gem 'simple_token_authentication'
```

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

If the model or models you chose have no `:authentication_token` attribute, add them one (with an index):

```bash
rails g migration add_authentication_token_to_users authentication_token:string:index
rake db:migrate
```

Finally define which controller will handle authentication (typ. `ApplicationController`) for which _token authenticatable_ model:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # ...

  acts_as_token_authentication_handler_for User

  # Security note: controllers with no-CSRF protection must disable the Devise fallback,
  # see #49 for details.
  # acts_as_token_authentication_handler_for User, fallback_to_devise: false

  # The token authentication requirement can target specific controller actions:
  # acts_as_token_authentication_handler_for User, only: [:create, :update, :destroy]
  # acts_as_token_authentication_handler_for User, except: [:index, :show]

  # Several token authenticatable models can be handled by the same controller.
  # If so, for all of them except the last, the fallback_to_devise should be disabled.
  #
  # Please do notice that the order of declaration defines the order of precedence.
  #
  # acts_as_token_authentication_handler_for Admin, fallback_to_devise: false
  # acts_as_token_authentication_handler_for SpecialUser, fallback_to_devise: false
  # acts_as_token_authentication_handler_for User # the last fallback is up to you

  # ...
end
```

Configuration
-------------

Some aspects of the behavior of _Simple Token Authentication_ can be customized with an initializer.
Below is an example with reasonable defaults:

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
  # config.header_names = { user: { authentication_token: 'X-User-Token', email: 'X-User-Email' } }

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

### Integration with other authentication methods

If sign-in is successful, no other authentication method will be run, but if it doesn't (the authentication params were missing, or incorrect) then Devise takes control and tries to `authenticate_user!` with its own modules. That behaviour can however be modified for any controller through the **fallback_to_devise** option.

**Important**: Please do notice that controller actions whithout CSRF protection **must** disable the Devise fallback for [security reasons][csrf]. Since Rails enables CSRF protection by default, this configuration requirement should only affect controllers where you have disabled it, which may be the case of API controllers.

  [csrf]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues/49

Documentation
-------------

### Executable documentation

The Cucumber scenarii describe how to setup demonstration applications for different use cases. While you can read the `rake` output, you may prefer to read it in HTML format: see `doc/features.html`. The file is generated automatically by Cucumber, if necessary, you can update it by yourself:

```bash
cd simple_token_authentication
rake features_html # generate the features documentation

# Open doc/features.html in your preferred web browser.
```

I find that HTML output quite enjoyable, I hope you'll do so!

### Frequently Asked Questions

Any question? Please don't hesitate to open a new issue to get help. I keep questions tagged to make possible to [review the open questions][open-questions], while closed questions are organized as a sort of [FAQ][faq].

  [open-questions]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues?labels=question&page=1&state=open
  [faq]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues?direction=desc&labels=question&page=1&sort=comments&state=closed

### Changelog

Releases are commented to provide a brief [changelog][changelog].

  [changelog]: https://github.com/gonzalo-bulnes/simple_token_authentication/releases

Development
-----------

### Testing (gem use cases)

Since `v1.0.0`, this gem development is test-driven. The gem use cases are described with [RSpec][rspec] within an example app. That app is generated and configured automatically by [Aruba][aruba] as a [Cucumber][cucumber] feature.

The resulting Cucumber features are a bit verbose, and their output when errors occur is not ideal, but their output when they are passing, on the contrary, provides an easy-to-reproduce recipe to build the example app (see [Executable documentation][exec-doc]). I find that useful enough to be patient with red scenarii for now.

  [aruba]: https://github.com/cucumber/aruba
  [cucumber]: https://github.com/cucumber/cucumber-rails
  [rspec]: https://www.relishapp.com/rspec/rspec-rails/docs
  [exec-doc]: https://github.com/gonzalo-bulnes/simple_token_authentication#executable-documentation

Beside the gem use cases, the behaviour of each component of the gem-- taken individually --is described using RSpec. That RSpec-only tests suite provides documentation of the public interfaces implemented by the gem components, and a few private ones (for development purpose only).

You can run the full test suite with `cd simple_token_authentication && rake`.

### Contributions

Contributions are welcome! I'm not personally maintaining any [list of contributors][contributors] for now, but any PR which references us all will be welcome.

  [contributors]: https://github.com/gonzalo-bulnes/simple_token_authentication/graphs/contributors

Credits
-------

It may sound a bit redundant, but this gem wouldn't exist without [this gist][original-gist].

License
-------

    Simple Token Authentication
    Copyright (C) 2013 Gonzalo Bulnes Guilpain

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
