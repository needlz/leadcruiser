ActiveAdmin.register Affiliate do
  permit_params :token

  form do |f|
    f.inputs 'Affiliate' do
      f.input :token, input_html: {
          value: loop do
            token = SecureRandom.urlsafe_base64(nil, false)
            break token unless Affiliate.exists?(token: token)
          end
      }
    end
    f.actions
  end
end
