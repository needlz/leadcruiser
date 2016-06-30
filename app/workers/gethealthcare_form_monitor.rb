require 'capybara'
require 'capybara/dsl'

class GethealthcareFormMonitor
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  include Capybara::DSL

  def perform

    hit_server
    delay_minutes = EditableConfiguration.global.gethealthcare_form_monitor_delay_minutes
    GethealthcareFormMonitor.perform_in(delay_minutes.minutes)
  end

  private

  def hit_server
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
    find('.maleRadio').click
    find('.age input').set('12/30/1994')
    find('.zipcode input').set('01001')
    find('.startBtnBox input').click

    #step_2
    sleep 2
    switch_to_window windows.last
    find('a.nextBtn1a').click

    #step_3
    sleep 2
    find('.noneCheck').click
    find('.nextBtn').click

    #step_4
    sleep 2
    find('.nextBtn').click

    #step_5
    sleep 2
    find('#step2b-height_ft').set('5')
    find('#step2b-height_in').set('2')
    find('#step2b-weight').set('170')
    find('.personConditions .noNo').click
    find('.personTobacco .noNo').click
    find('.nextBtnStep2b').click

    #step_6
    sleep 2
    find('#step3-firstname').set('test')
    find('#step3-lastname').set('test')
    find('#step3-email').set('example@test.com')
    find('#step3-phone').set('7871111111')
    find('#step3-address1').set('adress1')
    find('.seePlansNow').click
    pp page.driver.error_messages if Capybara.current_driver == :webkit_debug
    sleep 5
    switch_to_window windows.last
  end
end