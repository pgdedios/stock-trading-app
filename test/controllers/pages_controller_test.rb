require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get unconfirmed" do
    get pages_unconfirmed_url
    assert_response :success
  end

  test "should get pending_approval" do
    get pages_pending_approval_url
    assert_response :success
  end
end
