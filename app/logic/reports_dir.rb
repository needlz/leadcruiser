class ReportsDir

  REPORTS_DIR_PATH = 'reports'

  def self.s3_objects
    s3 = AWS::S3.new
    tree = s3.buckets[Settings.aws.bucket_name].objects.with_prefix(REPORTS_DIR_PATH)

    @records = tree.select { |obj| obj.key =~ Regexp.new("#{ Regexp.escape(REPORTS_DIR_PATH) }/.+") }
  end

  def self.add_report(filepath)
    s3_object(filepath).write(File.open(filepath, 'rb'), expires: expiration_time)
  end

  def self.expiration_time
    (Time.current + 30.days).strftime('%Y-%m-%d %H:%M:%S')
  end

  def self.s3_object(filepath)
    s3 = AWS::S3.new
    bucket = s3.buckets[Settings.aws.bucket_name]

    AWS::S3::S3Object.new(bucket, "#{ REPORTS_DIR_PATH }/#{ File.basename(filepath) }")
  end

end
