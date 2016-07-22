require 'rails_helper'

RSpec.describe EditableConfiguration, type: :model do

  before do
    EditableConfiguration.create!
  end

  describe '#inside_non_forwarding_range?' do
    context 'when inside non forwarding time range' do
      before do
        EditableConfiguration.global.update_attributes!(non_forwarding_range_start: Time.current - 1.minute,
                                                        non_forwarding_range_end: Time.current + 2.minutes)
      end

      it 'returns true' do
        expect(EditableConfiguration.global.inside_non_forwarding_range?).to be_truthy
      end
    end

    context 'when outside non forwarding time range' do
      before do
        EditableConfiguration.global.update_attributes!(non_forwarding_range_start: Time.current + 1.minute,
                                                        non_forwarding_range_end: Time.current + 2.minutes)
      end

      it 'returns false' do
        expect(EditableConfiguration.global.inside_non_forwarding_range?).to be_falsey
      end
    end

    context 'when non forwarding time range not set' do
      it 'returns false' do
        expect(EditableConfiguration.global.inside_non_forwarding_range?).to be_falsey
      end
    end
  end


end
