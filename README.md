Simple Token Authentication
===========================

[![Gem Version](https://badge.fury.io/rb/simple_token_authentication.png)](http://badge.fury.io/rb/simple_token_authentication)
[![Build Status](https://travis-ci.org/gonzalo-bulnes/simple_token_authentication.png?branch=master)](https://travis-ci.org/gonzalo-bulnes/simple_token_authentication)

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

Define which controller will handle authentication (typ. `ApplicationController`):

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # ...
  acts_as_token_authentication_handler

  # ...
end
```

Define which model or models will be token authenticatable (typ. `User`):

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

Usage
-----

### Tokens Generation

Assuming `user` is an instance of `User`, which is _token authenticatable_: each time `user` will be saved, and `user.authentication_token.is_blank?` it receives a new and unique authentication token (via `Devise.friendly_token`).

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

If sign-in is successful, no other authentication method will be run, but if it doesn't (the authentication params were missing, or incorrect) then Devise takes control and tries to `authenticate_user!` with its own modules.

Development
-----------

### Testing

Since `v1.0.0`, this gem development is test-driven. Each use case should be described with [RSpec][rspec] within an example app. That app will be created and configured automatically by [Aruba][aruba] as a [Cucumber][cucumber] feature.

The resulting Cucumber features are a bit verbose, and their output when errors occur is not ideal, but their output when they are passing, on the contrary, provides an easy to reproduce recipe to build the example app. I find that useful enough to be patient with red scenarii for now.

  [aruba]: https://github.com/cucumber/aruba
  [cucumber]: https://github.com/cucumber/cucumber-rails
  [rspec]: https://www.relishapp.com/rspec/rspec-rails/docs

You can run the full test suite with `cd simple_token_authentication && rake`.

### Contributions

Contributions are welcome! I'm not keeping a list of contributors for now, but any PR which references us all will be welcome.

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
