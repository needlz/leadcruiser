ActiveAdmin.register Affiliate do
  permit_params :token

  form do |f|
    f.inputs 'Affiliate' do
      f.input :token, input_html: { value: generate_token }
    end
    f.actions
  end
end

def generate_token
  loop do
    token = SecureRandom.urlsafe_base64
    break token unless Affiliate.exists?(token: token)
  end
end
