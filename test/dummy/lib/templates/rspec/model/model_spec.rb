require 'spec_helper'

<% module_namespacing do -%>
describe <%= class_name %> do

  # attributes
<% for attribute in attributes -%>

  it "has <%= indefinite_articlerize(attribute.name) %>" do
    should respond_to :<%= attribute.name %>
  end
<% end -%>

  # associations

  # Uncomment if your model has associations.
  # See https://github.com/thoughtbot/shoulda
  #
  # it "belongs to a 'model'" do
  #   should belong_to :model
  # end

  # validations

<% if options[:fixture_replacement] == :factory_girl -%>
  # See https://github.com/thoughtbot/factory_girl
  # This factory should only set the REQUIRED attributes.
  it "has a valid factory" do
    FactoryGirl.build(:<%= class_name.underscore %>).should be_valid
  end
  #
  # Uncomment if your model has required attributes.
  # This factory should set no attributes and is useful when invalid
  # attributes or objects are required.
  # See FactoryGirl.attributes_for() documentation
  #
  # it "has an invalid factory" do
  #   FactoryGirl.build(:invalid_<%= class_name.underscore %>).should be_valid
  # end

<% end -%>
  # Uncomment if your model has required attributes
  #
  # This is the BDD way of testing attributes presence validation
  # See https://www.relishapp.com/rspec/rspec-rails/docs/model-specs/errors-on
  #
  # it "fails validation with no 'attribute'" do
  #   expect(<%= class_name %>.new).to have(1).error_on(:attribute)
  # end
<% if options[:fixture_replacement] == :factory_girl -%>
  #
  # And this is an alternative way, which takes advantage of factories,
  # it's up to you to chose one, the other, or use both together.
  #
  # it "requires a 'attribute'" do
  #   FactoryGirl.build(:<%= class_name.underscore %>, attribute: "").should_not be_valid
  # end

<% end -%>
  # methods

  # Describe here you model methods behaviour.

end
<% end -%>
