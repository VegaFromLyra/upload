require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get files_url
    assert_response :success
  end

  test "presigned_url returns presigned data for valid image" do
    mock_response = { url: "https://bucket.s3.amazonaws.com", fields: { "key" => "uploads/test.png" } }
    S3PresignService.stub :presigned_url, mock_response do
      post presigned_url_files_url, params: { filename: "test.png", content_type: "image/png", file_size: 500_000 }, as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert json["url"].present?
    assert json["fields"].present?
  end

  test "presigned_url returns presigned data for valid pdf" do
    mock_response = { url: "https://bucket.s3.amazonaws.com", fields: { "key" => "uploads/doc.pdf" } }
    S3PresignService.stub :presigned_url, mock_response do
      post presigned_url_files_url, params: { filename: "doc.pdf", content_type: "application/pdf", file_size: 800_000 }, as: :json
    end

    assert_response :success
  end

  test "presigned_url rejects invalid content type" do
    post presigned_url_files_url, params: { filename: "script.exe", content_type: "application/x-msdownload", file_size: 500 }, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_match(/invalid file type/i, json["error"])
  end

  test "presigned_url rejects file exceeding size limit" do
    post presigned_url_files_url, params: { filename: "big.png", content_type: "image/png", file_size: 2_000_000 }, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_match(/1MB/i, json["error"])
  end

  test "presigned_url rejects missing parameters" do
    post presigned_url_files_url, params: { filename: "" }, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_match(/missing/i, json["error"])
  end

  test "presigned_url rejects zero file size" do
    post presigned_url_files_url, params: { filename: "test.png", content_type: "image/png", file_size: 0 }, as: :json

    assert_response :unprocessable_entity
  end

  test "presigned_url accepts all allowed image types" do
    mock_response = { url: "https://bucket.s3.amazonaws.com", fields: { "key" => "uploads/test" } }
    %w[image/jpeg image/png image/gif image/webp].each do |content_type|
      S3PresignService.stub :presigned_url, mock_response do
        post presigned_url_files_url, params: { filename: "test", content_type: content_type, file_size: 100 }, as: :json
      end

      assert_response :success, "Expected #{content_type} to be accepted"
    end
  end
end
