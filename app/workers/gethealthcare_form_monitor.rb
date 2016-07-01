require 'capybara'
require 'capybara/dsl'

class GethealthcareFormMonitor
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  PHONE_NUMBER_STATE_CODE = '787'
  TOTAL_PHONE_NUMBER_DIGITS = 10

  include Capybara::DSL

  def perform
    begin
      hit_server
    rescue StandardError => e
      if hit
        hit.update_attributes!(last_error: e.message)
      end
      if Rails.env.development?
        save_screenshot('/tmp/screens/file.png')
        p page.current_url
        p e
        p page.body
      else
        raise e
      end
    end
    delay_minutes = EditableConfiguration.global.gethealthcare_form_monitor_delay_minutes
    GethealthcareFormMonitor.perform_in(delay_minutes.minutes)
  end

  private

  attr_reader :hit

  def wait_until(&block)
    time_elapsed = 0
    start_time = Time.now
    done = false
    until time_elapsed > Capybara.default_max_wait_time || done
      done = block.call
      time_elapsed = Time.now - start_time
      sleep 0.2
    end
    done
  end

  def hit_server
    @hit = GethealthcareHit.create!

    submit_form

    hit.update_attributes!(finished_at: Time.now, result: result)
    check_threshold
  end

  def result
    (page.current_url == 'http://gethealthcare.co/next-steps') ? 'Failed' : 'Success'
  end

  def check_threshold
    if hit.duration > EditableConfiguration.global.gethealthcare_form_threshold_seconds
      # do anything yet
      
    end
  end

  def submit_form
    Capybara.reset_sessions!
    page.visit("/")

    #step 1
    find('.maleRadio').trigger("click")
    find('.age input').set('12/30/1994')
    find('.zipcode input').set('01001')
    find('.startBtnBox input').trigger("click")

    #step 1a "Would you like to add a family member?"
    switch_to_window windows.last
    find('a.nextBtn1a').trigger("click")

    #step 2 "Any Recent Life Events?"
    find('.noneCheck').trigger("click")
    find('.nextBtn').trigger("click")

    #step 2a "We need some information about your household to find you the right plans."
    find('.nextBtn').trigger("click")
    sleep 1
    find('.nextBtn').trigger("click")

    #step 2b "Okay, tell us more about your household."
    find('#step2b-height_ft').set('5')
    find('#step2b-height_in').set('2')
    find('#step2b-weight').set('170')
    find('.personConditions .noNo').trigger("click")
    find('.personTobacco .noNo').trigger("click")
    find('.nextBtnStep2b').trigger("click")

    #step_6
    find('#step3-firstname').set('test')
    find('#step3-lastname').set('test')
    find('#step3-email').set('test@test.com')
    find('#step3-phone').set(build_phone_number)
    find('#step3-address1').set('test')
    find('.seePlansNow').trigger("click")

    wait_until do
      p page.current_url
      page.current_url.start_with?('http://gethealthcare.co/thanks-page')
    end
    wait_until do
      p page.current_url
      page.current_url != 'http://gethealthcare.co/next-steps'
    end
  end

  def build_phone_number
    zero_count = phone_number_without_code_digits_count - next_hit_id.length

    PHONE_NUMBER_STATE_CODE + '0'*zero_count + next_hit_id
  end
  
  def next_hit_id
    (GethealthcareHit.last.id + 1).to_s
  end

  def phone_number_without_code_digits_count
    TOTAL_PHONE_NUMBER_DIGITS- PHONE_NUMBER_STATE_CODE.length
  end
end
