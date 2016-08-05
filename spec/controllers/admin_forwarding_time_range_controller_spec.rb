require 'rails_helper'

RSpec.describe Admin::ForwardingTimeRangesController, type: :controller do

  describe 'POST create' do
    let(:now) { Time.current }
    let(:begin_hour) { 2 }
    let(:params) {
      {'forwarding_time_range' =>
        {'kind' => 'afterhours',

         'begin_day' => 'Monday',
         'begin_time(1i)' => now.year,
         'begin_time(2i)' => now.month,
         'begin_time(3i)' => now.day,
         'begin_time(4i)' => begin_hour,
         'begin_time(5i)' => '00',

         'end_day' => 'Monday',
         'end_time(1i)' => now.year,
         'end_time(2i)' => now.month,
         'end_time(3i)' => now.day,
         'end_time(4i)' => '04',
         'end_time(5i)' => '00'
        }
      }
    }

    context 'during daylight time' do
      before do
        Timecop.travel(Time.local(now.year, 7, 1))
      end

      it 'sets hour using UTC-8' do
        post :create, params
        range = ForwardingTimeRange.last
        time = range.begin_time.in_time_zone
        expect(time.zone).to eq 'PST'
        expect(time.hour).to eq begin_hour
      end
    end

    context 'during standard time' do
      before do
        Timecop.travel(Time.local(now.year, 1, 1))
      end

      it 'sets hour using UTC-8' do
        post :create, params
        range = ForwardingTimeRange.last
        time = range.begin_time.in_time_zone
        expect(time.zone).to eq 'PST'
        expect(time.hour).to eq begin_hour
      end
    end

    it 'creates time range' do
      expect { post :create, params }.to change{ ForwardingTimeRange.count }.from(0).to(1)
    end
  end

end


