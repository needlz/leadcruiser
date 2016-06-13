require 'rails_helper'

RSpec.describe VisitorsController, :type => :controller do
  render_views

  context 'when navigating to homepage' do
    it 'renders template' do
      get :home
      expect(response).to render_template(:home)
    end
  end

end
