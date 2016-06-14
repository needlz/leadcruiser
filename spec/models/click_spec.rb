require 'rails_helper'


describe Click, type: :model do
  it 'should not create Click without visitor_ip and clients vertical' do
    click = Click.new ({ status: true })

    expect(click.invalid?).to be_truthy
    expect { click.save! }.to raise_error( ActiveRecord::RecordInvalid,
                                           "Validation failed: Visitor ip cannot be blank, Clients vertical cannot be blank" )
  end
end
