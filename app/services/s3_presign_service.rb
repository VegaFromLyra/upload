class S3PresignService
  MAX_FILE_SIZE = 1.megabyte
  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg
    image/png
    image/gif
    image/webp
    application/pdf
  ].freeze

  def self.valid_content_type?(content_type)
    ALLOWED_CONTENT_TYPES.include?(content_type)
  end

  def initialize(bucket: nil)
    @bucket = bucket || default_bucket
  end

  def presigned_url(filename:, content_type:)
    key = "uploads/#{SecureRandom.uuid}/#{filename}"

    presigned_post = @bucket.presigned_post(
      key: key,
      content_type: content_type,
      content_length_range: 1..MAX_FILE_SIZE,
      metadata: { "original-filename" => filename }
    )

    { url: presigned_post.url, fields: presigned_post.fields }
  end

  private

  def default_bucket
    credentials = Rails.application.credentials.aws
    client = Aws::S3::Client.new(
      region: credentials[:region],
      access_key_id: credentials[:access_key_id],
      secret_access_key: credentials[:secret_access_key]
    )
    Aws::S3::Resource.new(client: client).bucket(credentials[:bucket_name])
  end
end
