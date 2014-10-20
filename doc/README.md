Documentation
=============

**Looking for the HTML features decription?**

The Cucumber features that documented the gem behaviour until `v1.5.1` constituted a robust tests suite, but they were slow and writting them was difficult enough to become a continuous bottleneck.

I decided to tackle the issue by replacing most scenarios by unit tests (see [#104][issue]), and since `v1.5.2` the gem behaviour is documented using RSpec only.

I liked the [executable documentation][exec-doc] idea, and I do not discard using Cucumber again to test _Simple Token Authentication_.
However, truth is that neither the somewhat intricated [Cucumber][cucumber] - [Aruba][aruba] - [RSpec][rspec] setup or the steps I wrote were exemplary enough to make justice to the great tool Cucumber is. So I decided to stop maintaining  the features and to remove them. The RSpec test suite provides a nice [documentation][doc], and sometimes the best is a fresh start.

  [exec-doc]: https://github.com/gonzalo-bulnes/simple_token_authentication/tree/v1.5.1#executable-documentation
  [doc]: #testing-and-documentation
  [issue]: https://github.com/gonzalo-bulnes/simple_token_authentication/issues/104
  [aruba]: https://github.com/cucumber/aruba
  [cucumber]: https://github.com/cucumber/cucumber-rails
  [rspec]: https://www.relishapp.com/rspec/rspec-rails/docs
