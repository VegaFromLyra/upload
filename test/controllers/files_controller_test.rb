require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get files_url
    assert_response :success
  end

  test "generate a presigned url" do
    # Stub AWS S3 bucket and object
    stub_object = stub('s3_object')
    stub_bucket = stub('s3_bucket')
    stub_object.stubs(:presigned_url).with(:put).returns('https://test-bucket.s3.amazonaws.com/test-file.txt?presigned=true')
    stub_bucket.stubs(:object).with('test-file.txt').returns(stub_object)
    
    Aws::S3::Bucket.stubs(:new).with(Rails.application.credentials.aws.bucket_name).returns(stub_bucket)
    
    post presigned_url_files_path, params: { filename: 'test-file.txt' }
    
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal 'https://test-bucket.s3.amazonaws.com/test-file.txt?presigned=true', response_body['url']
  end

  test "sanitizes path traversal attack in filename" do
    expected_presigned_url = 'https://test-bucket.s3.amazonaws.com/passwd?presigned=true'
    
    # Mock AWS S3 bucket and object
    stub_object = stub('s3_object')
    mock_bucket = mock('s3_bucket')
    stub_object.stubs(:presigned_url).with(:put).returns(expected_presigned_url)
    
    # Expect the bucket to receive object call with sanitized filename
    mock_bucket.expects(:object).with('passwd').returns(stub_object)
    
    Aws::S3::Bucket.stubs(:new).with(Rails.application.credentials.aws.bucket_name).returns(mock_bucket)
    
    # Attempt path traversal attack
    post presigned_url_files_path, params: { filename: '../../etc/passwd' }
  end
end
