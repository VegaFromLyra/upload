class FilesController < ApplicationController
  def index
  end

  def presigned_url
    filename = params[:filename]
    content_type = params[:content_type]
    file_size = params[:file_size].to_i

    unless filename.present? && content_type.present? && file_size.positive?
      return render json: { error: "Missing required parameters" }, status: :unprocessable_entity
    end

    unless S3PresignService.valid_content_type?(content_type)
      return render json: { error: "Invalid file type. Only images and PDFs are allowed." }, status: :unprocessable_entity
    end

    if file_size > S3PresignService::MAX_FILE_SIZE
      return render json: { error: "File size exceeds 1MB limit." }, status: :unprocessable_entity
    end

    presigned_data = S3PresignService.presigned_url(filename: filename, content_type: content_type)
    render json: presigned_data
  end
end
