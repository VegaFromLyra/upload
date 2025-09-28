require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get files_url
    assert_response :success
  end
end
