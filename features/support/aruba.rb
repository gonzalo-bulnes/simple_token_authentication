require 'aruba/cucumber'

Before do
  @dirs = ["test/dummy"]
end

Before('@rspec') do
  @aruba_timeout_seconds = 10
end
