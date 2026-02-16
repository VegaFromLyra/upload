require "test_helper"

class S3PresignServiceTest < ActiveSupport::TestCase
  test "valid_content_type? accepts image/jpeg" do
    assert S3PresignService.valid_content_type?("image/jpeg")
  end

  test "valid_content_type? accepts image/png" do
    assert S3PresignService.valid_content_type?("image/png")
  end

  test "valid_content_type? accepts image/gif" do
    assert S3PresignService.valid_content_type?("image/gif")
  end

  test "valid_content_type? accepts image/webp" do
    assert S3PresignService.valid_content_type?("image/webp")
  end

  test "valid_content_type? accepts application/pdf" do
    assert S3PresignService.valid_content_type?("application/pdf")
  end

  test "valid_content_type? rejects text/plain" do
    assert_not S3PresignService.valid_content_type?("text/plain")
  end

  test "valid_content_type? rejects application/zip" do
    assert_not S3PresignService.valid_content_type?("application/zip")
  end

  test "MAX_FILE_SIZE is 1 megabyte" do
    assert_equal 1.megabyte, S3PresignService::MAX_FILE_SIZE
  end

  test "presigned_url returns url and fields" do
    mock_post = Minitest::Mock.new
    mock_post.expect(:url, "https://bucket.s3.amazonaws.com")
    mock_post.expect(:fields, { "key" => "uploads/uuid/test.png", "policy" => "encoded" })

    mock_bucket = Minitest::Mock.new
    mock_bucket.expect(:presigned_post, mock_post) do |**kwargs|
      kwargs[:key].is_a?(String) &&
        kwargs[:content_type] == "image/png" &&
        kwargs[:content_length_range] == (1..1.megabyte)
    end

    service = S3PresignService.new(bucket: mock_bucket)
    result = service.presigned_url(filename: "test.png", content_type: "image/png")

    assert result[:url].present?
    assert result[:fields].present?

    mock_post.verify
    mock_bucket.verify
  end
end
