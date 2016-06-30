require 'capybara'
require 'capybara/dsl'

module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

class GethealthcareFormMonitor
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  include Capybara::DSL
  include WaitForAjax

  def perform
    begin
      hit_server
    rescue Capybara::ElementNotFound => e
      if Rails.env.development?
        save_screenshot('/screens/file.png')
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

  def wait_until(&block)
    time_elapsed = 0
    start_time = Time.now
    done = false
    until time_elapsed > Capybara.default_max_wait_time || done
      done = block.call
      time_elapsed = Time.now - start_time
      sleep 0.5
    end
    done
  end

  def hit_server
    Capybara.reset_sessions!
    page.visit("/")

    hit = GethealthcareHit.new
    hit.created_at = Time.now

    submit_form

    hit.finished_at = Time.now
    pp page.current_url
    hit.result = (page.current_url == 'http://gethealthcare.co/next-steps') ? 'Failed' : 'Success'
    hit.save!
  end

  def submit_form
    #step_1
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
    find('#step3-email').set('example@test.com')
    find('#step3-phone').set('7871111111')
    find('#step3-address1').set('adress1')
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
end