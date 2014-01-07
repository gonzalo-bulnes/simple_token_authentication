require 'spec_helper'

describe "private_posts/show" do
  before(:each) do
    @private_post = assign(:private_post, stub_model(PrivatePost,
      :title => "Title",
      :body => "MyText",
      :published => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/false/)
  end
end
