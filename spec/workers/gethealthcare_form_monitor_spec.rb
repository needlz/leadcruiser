require 'rails_helper'

RSpec.describe GethealthcareFormMonitor do

  let(:notification_resipients) { ['email_1@example.com', 'email_2@example.com'] }
  let!(:editable_configuration) {
    EditableConfiguration.create!(gethealthcare_notified_recipients_comma_separated: notification_resipients.join(',  '))
  }

  context 'when successful form submission' do
    def mock_successful_gethealthcare_form_submission
      allow_any_instance_of(GethealthcareFormMonitor).to receive(:submit_form)
      allow_any_instance_of(GethealthcareFormMonitor).to receive(:result) { 'Success' }
    end

    before do
      mock_successful_gethealthcare_form_submission
    end

    context 'when hit duration exceeded threshold' do
      before do
        allow_any_instance_of(GethealthcareHit).to receive(:duration) {
          EditableConfiguration.global.gethealthcare_form_threshold_seconds + 1.second
        }
      end
    end

    context 'when hit duration does not exceed threshold' do
      before do
        allow_any_instance_of(GethealthcareHit).to receive(:duration) {
          EditableConfiguration.global.gethealthcare_form_threshold_seconds - 1.second
        }
      end
    end
  end

  context 'when form raise error' do
    let(:error) { StandardError }

    def mock_gethealthcare_form_submission_with_error
      allow_any_instance_of(GethealthcareFormMonitor).to receive(:submit_form) { raise(error) }
    end

    before do
      mock_gethealthcare_form_submission_with_error
    end
  end

end
