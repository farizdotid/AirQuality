require "test_helper"

class AirQualityControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get air_quality_index_url
    assert_response :success
  end
end
