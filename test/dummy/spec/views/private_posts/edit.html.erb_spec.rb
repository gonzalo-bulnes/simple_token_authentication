require 'spec_helper'

describe "private_posts/edit" do
  before(:each) do
    @private_post = assign(:private_post, stub_model(PrivatePost,
      :title => "MyString",
      :body => "MyText",
      :published => false
    ))
  end

  it "renders the edit private_post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", private_post_path(@private_post), "post" do
      assert_select "input#private_post_title[name=?]", "private_post[title]"
      assert_select "textarea#private_post_body[name=?]", "private_post[body]"
      assert_select "input#private_post_published[name=?]", "private_post[published]"
    end
  end
end
