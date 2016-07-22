require 'rails_helper'

RSpec.describe EditableConfiguration, type: :model do

  before do
    EditableConfiguration.create!
  end

  describe '#inside_afterhours_range?' do
    context 'when inside non forwarding time range' do
      before do
        EditableConfiguration.global.update_attributes!(afterhours_range_start: Time.current - 1.minute,
                                                        afterhours_range_end: Time.current + 2.minutes)
      end

      it 'returns true' do
        expect(EditableConfiguration.global.inside_afterhours_range?).to be_truthy
      end
    end

    context 'when outside non forwarding time range' do
      before do
        EditableConfiguration.global.update_attributes!(afterhours_range_start: Time.current + 1.minute,
                                                        afterhours_range_end: Time.current + 2.minutes)
      end

      it 'returns false' do
        expect(EditableConfiguration.global.inside_afterhours_range?).to be_falsey
      end
    end

    context 'when non forwarding time range not set' do
      it 'returns false' do
        expect(EditableConfiguration.global.inside_afterhours_range?).to be_falsey
      end
    end
  end


end
