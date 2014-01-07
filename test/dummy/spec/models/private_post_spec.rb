require 'spec_helper'

describe PrivatePost do

  # attributes

  it "has a title" do
    should respond_to :title
  end

  it "has a body" do
    should respond_to :body
  end

  it "has a published" do
    should respond_to :published
  end

  # associations

  # Uncomment if your model has associations.
  # See https://github.com/thoughtbot/shoulda
  #
  # it "belongs to a 'model'" do
  #   should belong_to :model
  # end

  # validations

  # See https://github.com/thoughtbot/factory_girl
  # This factory should only set the REQUIRED attributes.
  it "has a valid factory" do
    FactoryGirl.build(:private_post).should be_valid
  end
  #
  # Uncomment if your model has required attributes.
  # This factory should set no attributes and is useful when invalid
  # attributes or objects are required.
  # See FactoryGirl.attributes_for() documentation
  #
  it "has an invalid factory" do
    FactoryGirl.build(:invalid_private_post).should_not be_valid
  end

  # Uncomment if your model has required attributes
  #
  # This is the BDD way of testing attributes presence validation
  # See https://www.relishapp.com/rspec/rspec-rails/docs/model-specs/errors-on
  #
  # it "fails validation with no 'attribute'" do
  #   expect(PrivatePost.new).to have(1).error_on(:attribute)
  # end
  #
  # And this is an alternative way, which takes advantage of factories,
  # it's up to you to chose one, the other, or use both together.
  #
  it "requires a 'title'" do
    FactoryGirl.build(:private_post, title: "").should_not be_valid
  end

  # methods

  # Describe here you model methods behaviour.

end
