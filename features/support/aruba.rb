require 'aruba/cucumber'

Before do
  @dirs = ["spec/dummy"]
end

Before('@rspec') do
  @aruba_timeout_seconds = 10
end
