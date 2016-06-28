namespace :gethealthcare do
  desc "Fills the form and submits it"
  task hit: :environment do
    require 'capybara'
    require 'capybara/dsl'

    include Capybara::DSL

    Capybara.current_driver = :selenium
    Capybara.app_host = "http://gethealthcare.co/"

    page.visit("/")

    hit = GethealthcareHit.new
    hit.created_at = Time.now

    submit_form

    hit.finished_at = Time.now
    hit.result = (page.current_url == 'http://gethealthcare.co/next-steps') ? 'Failed' : 'Success'
    hit.save!
  end

  private

  def submit_form
    #step_1
    find('.maleRadio').click
    find('.age input').set('12/30/1994')
    find('.zipcode input').set('01001')

    new_window = window_opened_by { find('.startBtnBox input').click }
    switch_to_window new_window

    #step_2
    sleep 2
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
    find('#step3-firstname').set('firstname')
    find('#step3-lastname').set('lastname')
    find('#step3-email').set('example@test.com')
    find('#step3-phone').set('7871111111')
    find('#step3-address1').set('adress1')
    find('.seePlansNow').click
    sleep 5
  end
end