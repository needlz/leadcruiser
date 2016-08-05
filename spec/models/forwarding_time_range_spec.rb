require 'rails_helper'

RSpec.describe ForwardingTimeRange, type: :model do

  let(:now) { Time.current }

  before do
    EditableConfiguration.create!
  end

  describe '#inside_afterhours_range?' do
    context 'during daylight time' do
      before do
        Timecop.travel(Time.local(Time.current.year, 7, 1, 5, 0))
      end

      context 'when inside afterhours time range' do
        context 'when range covers two days' do
          before do
            default_year = Time.parse('2000-01-01')
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                                   end_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers one day' do
          before do
            default_year = Time.parse('2000-01-01')
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[now.wday],
                                                   end_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) + 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers different weeks' do
          before do
            default_year = Time.parse('2000-01-01')
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[0],
                                                   end_time: default_year.in_time_zone(-8).change(hour: 0, min: 0))
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end
      end
    end

    context 'during standard time' do
      before do
        Timecop.travel(Time.local(Time.current.year, 1, 1, 5, 0))
      end

      context 'when inside afterhours time range' do
        context 'when range covers two days' do
          before do
            default_year = Time.parse('2000-01-01')
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                                   end_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers one day' do
          before do
            default_year = Time.parse('2000-01-01')
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[now.wday],
                                                   end_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) + 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers different weeks' do
          before do
            default_year = Time.parse('2000-01-01')
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[0],
                                                   end_time: default_year.in_time_zone(-8).change(hour: 0, min: 0))
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end
      end
    end

    context 'when afterhours time range not set' do
      it 'returns false' do
        expect(ForwardingTimeRange.inside_afterhours_range?).to be_falsey
      end
    end
  end

end
