require 'rails_helper'

RSpec.describe Admin::ForwardingTimeRangesController, type: :controller do

  describe 'POST create' do
    let(:now) { Time.current }
    let(:begin_hour) { 2 }
    let(:afterhours_params) {
      {'forwarding_time_range' =>
        {'kind' => 'afterhours',

         'begin_day' => 'Monday',
         'begin_time(1i)' => now.year,
         'begin_time(2i)' => now.month,
         'begin_time(3i)' => now.day,
         'begin_time(4i)' => begin_hour,
         'begin_time(5i)' => '30',

         'end_day' => 'Monday',
         'end_time(1i)' => now.year,
         'end_time(2i)' => now.month,
         'end_time(3i)' => now.day,
         'end_time(4i)' => '04',
         'end_time(5i)' => '30'
        }
      }
    }
    let(:forwarding_params) {
      {'forwarding_time_range' =>
         {'kind' => 'forwarding',

          'begin_day' => 'Monday',
          'begin_time(1i)' => now.year,
          'begin_time(2i)' => now.month,
          'begin_time(3i)' => now.day,
          'begin_time(4i)' => begin_hour,
          'begin_time(5i)' => '30',

          'end_day' => 'Monday',
          'end_time(1i)' => now.year,
          'end_time(2i)' => now.month,
          'end_time(3i)' => now.day,
          'end_time(4i)' => '04',
          'end_time(5i)' => '30'
         }
      }
    }

    context 'during daylight time' do
      before do
        Timecop.travel(Time.local(now.year, 7, 1))
      end

      it 'sets hour using UTC-8' do
        post :create, afterhours_params
        range = ForwardingTimeRange.last
        time = range.begin_time.in_time_zone
        expect(time.zone).to eq 'PST'
        expect(time.hour).to eq begin_hour
        expect(time.min).to eq 30
      end

      context 'when creating forwarding range' do
        it 'schedules forwarding job' do
          pending
          expect { post :create, forwarding_params }.to enqueue_a(ForwardLeadsToBoberdooJob)
        end
      end
    end

    context 'during standard time' do
      before do
        Timecop.travel(Time.local(now.year, 1, 1))
      end

      it 'sets hour using UTC-8' do
        post :create, afterhours_params
        range = ForwardingTimeRange.last
        time = range.begin_time.in_time_zone
        expect(time.zone).to eq 'PST'
        expect(time.hour).to eq begin_hour
      end
    end

    it 'creates time range' do
      expect { post :create, afterhours_params }.to change{ ForwardingTimeRange.count }.from(0).to(1)
    end
  end

end


