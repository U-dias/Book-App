require "test_helper"

class ReadHistoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get read_histories_index_url
    assert_response :success
  end

  test "should get show" do
    get read_histories_show_url
    assert_response :success
  end
end
