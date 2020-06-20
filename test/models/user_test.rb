require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do 
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end

  test "email should not be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = 'a' * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid address" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
      first.last@foo.jp alice+bob@baz.cn]
    
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end 

  test "email validation should reject invalid address" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
      foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email address should be saved as lower-case" do 
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email 
  end 

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do 
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end 

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem impsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy 
    end
  end

  test "Should follow and unfollow a user" do
    zach = users(:zach)
    bob = users(:bob)
    assert_not zach.following?(bob)
    zach.follow(bob)
    assert zach.following?(bob)
    assert bob.followers.include?(zach)
    zach.unfollow(bob)
    assert_not zach.following?(bob)  
  end

  test "feed should have the right posts" do
    zach = users(:zach)
    bob = users(:bob)
    lana = users(:lana)

    #posts from followed user 
    lana.microposts.each do |post_following|
      assert zach.feed.include?(post_following)
    end
    
    #self posts for user with followers 
    zach.microposts.each do |post_self|
      assert zach.feed.include?(post_self)
    end
    
    # self-posts for user with no followers
    bob.microposts.each do |post_self|
      assert bob.feed.include?(post_self)
    end

    #posts from unfollowed user
    bob.microposts.each do |post_unfollowed|
      assert_not zach.feed.include?(post_unfollowed)
    end
  end
end

