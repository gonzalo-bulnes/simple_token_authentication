# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.17.0] - 2019-09-21

### Added

- Add Rails 6 support for Mongoid adapter - @unused

## [1.16.0] - 2019-08-20

### Added

- Add Rails 6 support - @MatthiasRMS

### Fixed

- Removed the `Gemfile.lock` - mostly to acknowledge that it was used only in development and is not really needed.

## [1.15.1] - 2017-01-26

### Fixed

- Work around [jbuilder][jbuilder] issues caused by the Rails API adapter - @IvRRimum with help from @Pepan

  [jbuilder]: https://github.com/rails/jbuilder

## [1.15.0] - 2017-01-14

### Added

- Support for hooks, specifically `after_successful_token_authentication` for now
- A Contributor Code of Conduct to ensure everyone feels safe contributing

## [1.14.0] - 2016-07-09

### Added

- Rails 5 support - with help from @chrisvel, @fighterii and @jblac

### Changed

- Travis CI now only relies on [Appraisal][appraisal] for dependency management

  [appraisal]: https://github.com/thoughtbot/appraisal

## [1.13.0] - 2016-04-20

### Added

- Support for Devise 4
- This change log : )

### Changed

- The [Travis CI build matrix][matrix] to improve the regression testing coverage
- The migration suggestion to make it safer - by @halilim

  [matrix]: https://github.com/gonzalo-bulnes/simple_token_authentication/blob/v1.13.0/.travis.yml

## [1.12.0] - 2016-01-06

### Added

- [Rails Metal][rails-metal] support, using the public adapter interface : ) - @singfoom

  [rails-metal]: http://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal

## [1.11.0] - 2015-12-14

### Added

- Support for the [Devise custom finders][devise-custom-finders], _Simple Token Authentication_ now uses the customizable [`find_for_authentication`][find-for-authentication] method to retrieve records. - @lowjoel

### Changed

- The license identifier format to match the [SPDX][spdx] guidelines

  [devise-custom-finders]: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address#tell-devise-to-use-username-in-the-authentication_keys
  [find-for-authentication]: https://github.com/plataformatec/devise/blob/v3.2/lib/devise/models/authenticatable.rb#L222-L243
  [spdx]: https://spdx.org/licenses

## [1.10.1] - 2015-11-10

### Added

- The `NoAdapterAvailableError` now provides details about its cause and hints to solve it.
- A **Testing** section to the [`README`][testing] - John Mosesman

  [testing]: https://github.com/gonzalo-bulnes/simple_token_authentication/tree/v1.12.0#testing

### Fixed

- An unnecessary Ruby 2.0 requirement caused by an indirect dependency, let's keep backward compatibility as long as possible
- A couple of typos - @eliotsykes and @jtperreault

## [1.10.0] - 2015-06-03

### Added

- The **fallback** option, and support for the `fallback: :exception` which mimics the Devise behaviour when authentication fails

### Changed

- The **fallback_to_devise** option to `fallback: :devise` and `fallback: :none` to get more flexibility and be able to support `fallback: :exception`. The older syntax is not officially deprecated, but using the **fallback** option is completely equivalent, and recommended.

## [1.9.1] - 2015-04-28

### Fixed

- The Mongoid adapter loading (which I did break when refactoring **v1.9.0**) - fixed with help from @krsyoung

## [1.9.0] - 2015-04-24

### Added

- More filters to scope `acts_as_token_authentication_handler_for`: `:if` and `:unless`, expected to be used with a Proc.
- Alias names for _token authenticatable_ classes can now be defined (in the token authentication handlers declarations): e.g. `acts_as_token_authentication_handler_for Vehicle::User, as: pilot`

### Fixed

- Errors defining namespaced classes as _token authenticatable_, by allowing _aliases_ to be defined for them - with help from @joshblour, @jessesandford, @ivan-kolmychek and @bbuchalter

## [1.8.0] - 2015-02-21

### Added

- Custom **identifiers** option, using other fileds than `:email` to identify records is now possible. When this option is in use, the default _header names_ are updated acordingly. - @nicolo
- The **skip_devise_trackable** option - @nMustaki

### Fixed

- A typo - @joelparkerhenderson

## [1.7.0] - 2014-11-27

### Added

- [Rails API][rails-api] support, controllers which inherit from `ActionController::API` can now be _token Authentication handlers_! - with help from @DeepAnchor
- Integration with [Devise case-insensitive keys][case], keys configured to be case insensitive in Devise are now automatically case insensitive in _Simple Token Authentication_ as well - @munkius
- Some important inline documentation

  [case]: https://github.com/plataformatec/devise/blob/v3.4.1/lib/generators/templates/devise.rb#L45-L48
  [rails-api]: https://github.com/rails-api/rails-api

## [1.6.0] - 2014-10-24

### Added

- Mongoid support, using the adapter interface : )

## [1.5.2] - 2014-10-21

### Added

- Public specification of the adapter interface
- Documentation about the new specs and how to contribute

### Fixed

- The option **header_names** can now also be used to set a single custom header, either for the identifier (e.g. `user_email`) or the token (e.g. `user_token`). Previously, setting both at once was required.
- Memoization implementation error in several class methods. The bug didn't modify the public behaviour of the gem, but did create bunches of instances of `EntityManager` and `FallbackAuthenticationHandler` without necessity.

### Removed

- The Cucumber features, in favor of faster and more flexible RSpec specs

### Changed

- The internal syntax for the **fallabck_to_devise** option is now `fallback: :devise` and `fallback: :none` for added flexibility. The change is transparent for end users, and will only be made official if new fallback mechanisms are introduced.
- Refactored heavily the code base to allow the introduction of the RSpec test suite, contributing should now be a lot easier
- Optional dependencies (e.g. ActiveRecord, ActionController) are now encapsulated into independent adapters

## [1.5.1] - 2014-09-18

### Added

- Support for Devise 3.3 - @prabode

## [1.5.0] - 2014-05-31

### Added

- Support for multiple Devise scopes per _token authentication handler_, a single controller can now independently handle token authentication for `User` and `AdminUser` for example - @donbobka

## [1.4.0] - 2014-05-24

### Added

- Filters to scope `acts_as_token_authentication_handler_for`: `:only` and `:except`, so token authentication handling can be restricted to a set of controller actions - @donbobka

### Changed

- The authentication token condition of existence for improved readability - @lenart

## [1.3.0] - 2014-05-17

### Added

- The **fallback_to_devise** option allows to disable the default fallback to Devise authentication when token authentication fails - @donbobka

### Security

- Add documentation: the fallback to Devise MUST be disabled when CSRF protection is disabled (often the case for API controllers)

## [1.2.1] - 2014-04-26

### Fixed

- The integration with Devise trackable, the sign in count is no longer increased when token authentication succeeds - @adamniedzielski
- A typo - @nickveys

## [1.2.0] - 2014-02-24

### Added

- Configuration framework, allows _Simple Token Authentication_ to be configured using an initializer - @krsyoung and @joel
- The **sign_in_token** option allows to create persistent sessions when token authentiation succeeds (can be used to sign in users from a link in an e-mail, for example) - @krsyoung
- The **header_names** option allows to define custom names for HTTP headers, e.g. `X-User-Authentication-Token`

## [1.1.1] - 2014-02-20

### Fixed

- The Travis CI build is now testing the correct release, I did make a mistake when releasing **v1.1.0**

## [1.1.0] - 2014-02-20

### Added

- Add support for multiple _token authenticatable_ classes, any model known to Devise can now be made _token authenticatable_, not only `User` - @invernizzi


## [1.0.1] - 2014-01-26

### Changed

- Nothing, this is a replacement for **v1.0.0** (because I messed up with Rubygems)

## [1.0.0] - 2014-01-26 [YANKED]

### Added

- A test suite, using Cucumber : )

## [1.0.0.pre.5] - 2014-01-09

### Fixed

- Authentication was required as soon as the gem was loaded - reported by @pdobb and @AhmedAttyah

## Changed

- Use the Bundler-friendly format for version numbers instead of follwing strictly the Semantic Versionning specification

## [1.0.0-beta.4] - 2013-12-26

### Fixed

- The user record is now fetched using `find_by_email` when `find_by` is not present (Rails 3.2) - with help from @AhmedAttyah

## [1.0.0-beta.3] - 2013-12-17

### Fixed

- Redundant dependencies: _Simple Token Authentication_ only depends on ActionMailer and ActiveRecord, not Rails

## [1.0.0-beta.2] - 2013-12-16

### Added

- Explicit dependency on Devise

## 1.0.0-beta - 2013-12-16

### Added

- Documentation

## Previously

This [gist][gist] did refactor the Jose Valim's code into an `ActiveSupport::Concern`.

[gist]: https://gist.github.com/gonzalo-bulnes/7659739
[Unreleased]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.17.0...master
[1.17.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.16.0...v1.17.0
[1.16.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.15.1...v1.16.0
[1.15.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.15.0...v1.15.1
[1.15.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.14.0...v1.15.0
[1.14.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.13.0...v1.14.0
[1.13.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.12.0...v1.13.0
[1.12.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.11.0...v1.12.0
[1.11.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.10.1...v1.11.0
[1.10.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.10.0...v1.10.1
[1.10.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.9.1...v1.10.0
[1.9.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.5.2...v1.6.0
[1.5.2]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.0.pre.5...v1.0.0
[1.0.0.pre.5]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.0-beta.4...v1.0.0.pre.5
[1.0.0-beta.4]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.0-beta.3...v1.0.0-beta.4
[1.0.0-beta.3]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.0-beta.2...v1.0.0-beta.3
[1.0.0-beta.2]: https://github.com/gonzalo-bulnes/simple_token_authentication/compare/v1.0.0-beta...v1.0.0-beta.2

## Inspiration

Thanks to @nTraum for pointing me at http://keepachangelog.com and to @olivierlacan for writing it in the first place!
