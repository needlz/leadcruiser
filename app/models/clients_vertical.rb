class ClientsVertical < ActiveRecord::Base
  
  belongs_to :lead, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  belongs_to :vertical
  after_commit :refresh_queue

  has_attached_file :logo,
                    :styles => {
                        :medium => "200x100>",
                        :thumb => "30x15>"
                    }#,
                    # url: ':s3_domain_url',
                    # :s3_credentials => {
                    #   :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                    #   :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    # },
                    # bucket: ENV['S3_BUCKET_NAME']
                    
                    
  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/
  
  def refresh_queue
    self.vertical.update_attributes(next_client: nil)
  end
end
