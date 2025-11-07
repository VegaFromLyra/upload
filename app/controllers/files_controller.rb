class FilesController < ApplicationController
  def index
  end

  def presigned_url
    bucket = Aws::S3::Bucket.new(Rails.application.credentials.aws.bucket_name)

    filename = params.require(:filename) # need to sanitize

    presigned_url_result = bucket.object(filename).presigned_url(:put)

    render json: {
      url: presigned_url_result
    }
  end
end
