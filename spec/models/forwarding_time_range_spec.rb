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

      context 'when outside of afterhours time range' do
        context 'when range covers different weeks' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[0],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min),
                                                   end_day: Date::DAYNAMES[1],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min))
            Timecop.travel(Time.current.at_beginning_of_week + 1.day)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_falsey
          end
        end
      end

      context 'when inside afterhours time range' do
        context 'when range covers two days' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers one day' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[now.wday],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) + 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers different weeks' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[0],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 0, min: 0))
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
        context 'when range covers different weeks' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[6],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 18, min: 0),
                                                   end_day: Date::DAYNAMES[1],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 6, min: 0))
            Timecop.travel(DateTime.current.at_beginning_of_week + 3.hours)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers two days' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 2.minutes)
          end

          it 'returns true' do
            expect(ForwardingTimeRange.inside_afterhours_range?).to be_truthy
          end
        end

        context 'when range covers one day' do
          before do
            ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                   begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                                   end_day: Date::DAYNAMES[now.wday],
                                                   end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) + 2.minutes)
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

  describe '#closest_or_current_forwarding_range' do
    context 'closest range is in future' do
      let!(:later_range) do
        ForwardingTimeRange.forwarding.create!(begin_day: Date::DAYNAMES[now.wday + 2] % 7,
                                               begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                               end_day: Date::DAYNAMES[now.wday + 2] % 7,
                                               end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 1, min: 1))
      end
      let!(:earlier_range) do
        ForwardingTimeRange.forwarding.create!(begin_day: Date::DAYNAMES[now.wday + 1] % 7,
                                               begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                               end_day: Date::DAYNAMES[now.wday + 1] % 7,
                                               end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 2, min: 2))
      end

      it 'returns earlier range' do
        expect(ForwardingTimeRange.closest_or_current_forwarding_range[:end].min).to eq(2)
      end
    end

    context 'closest range is in future' do
      let!(:later_range) do
        ForwardingTimeRange.forwarding.create!(begin_day: Date::DAYNAMES[now.wday + 2] % 7,
                                               begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 0, min: 0),
                                               end_day: Date::DAYNAMES[now.wday + 2] % 7,
                                               end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 1, min: 1))
      end
      let!(:earlier_range) do
        ForwardingTimeRange.forwarding.create!(begin_day: Date::DAYNAMES[now.wday + 1] % 7,
                                               begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 0, min: 0),
                                               end_day: Date::DAYNAMES[now.wday + 1] % 7,
                                               end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 2, min: 2))
      end
      let!(:running_range) do
        ForwardingTimeRange.forwarding.create!(begin_day: Date::DAYNAMES[now.wday],
                                               begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 0, min: 0),
                                               end_day: Date::DAYNAMES[now.wday + 1] % 7,
                                               end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: 3, min: 3))
      end

      it 'returns earlier range' do
        expect(ForwardingTimeRange.closest_or_current_forwarding_range[:end].min).to eq(3)
      end
    end
  end

end
