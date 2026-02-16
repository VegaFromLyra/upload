class FilesController < ApplicationController
  before_action :validate_presign_params, only: :presigned_url

  def index
  end

  def presigned_url
    presigned_data = S3PresignService.new.presigned_url(
      filename: presign_params[:filename],
      content_type: presign_params[:content_type]
    )
    render json: presigned_data
  end

  private

  def presign_params
    params.permit(:filename, :content_type, :file_size)
  end

  def validate_presign_params
    unless presign_params[:filename].present? && presign_params[:content_type].present? && presign_params[:file_size].to_i.positive?
      return render json: { error: "Missing required parameters" }, status: :unprocessable_entity
    end

    unless S3PresignService.valid_content_type?(presign_params[:content_type])
      return render json: { error: "Invalid file type. Only images and PDFs are allowed." }, status: :unprocessable_entity
    end

    if presign_params[:file_size].to_i > S3PresignService::MAX_FILE_SIZE
      render json: { error: "File size exceeds 3MB limit." }, status: :unprocessable_entity
    end
  end
end
