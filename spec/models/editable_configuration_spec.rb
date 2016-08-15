require 'rails_helper'

RSpec.describe EditableConfiguration, type: :model do

  before do
    EditableConfiguration.create!
  end

  describe 'on save' do
    it 'validates forwarding interval is positive' do
      config = EditableConfiguration.global
      config.update_attributes(forwarding_interval_minutes: 0)
      expect(config.errors.messages.keys).to include(:forwarding_interval_minutes)

      config.update_attributes(forwarding_interval_minutes: -1)
      expect(config.errors.messages.keys).to include(:forwarding_interval_minutes)

      config.update_attributes(forwarding_interval_minutes: 3)
      expect(config.errors.messages.keys).to_not include(:forwarding_interval_minutes)
    end
  end

end
