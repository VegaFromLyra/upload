class FilesController < ApplicationController
  def index
  end

  def presigned_url
    render json: {
      url: "https://example-bucket.s3.amazonaws.com",
      fields: {
        key: "uploads/#{SecureRandom.uuid}/#{params[:filename]}",
        policy: "example-policy",
        "x-amz-credential": "example-credential",
        "x-amz-algorithm": "AWS4-HMAC-SHA256",
        "x-amz-date": Time.current.strftime("%Y%m%dT%H%M%SZ"),
        "x-amz-signature": "example-signature"
      }
    }
  end
end
