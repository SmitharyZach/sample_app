require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup 
    @user = users(:zach)
  end

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path 
    assert_select "a[href=?]", about_path 
    assert_select "a[href=?]", contact_path 
    get contact_path
    assert_select "title", full_title("Contact")
  end

  test "Users page loads with correct user" do
    log_in_as(@user)
    get users_path
    assert_select "title", full_title("All users")
    assert_select 'li'
  end
end
