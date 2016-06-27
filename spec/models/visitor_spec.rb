require 'rails_helper'

RSpec.describe Visitor, type: :model do

  describe 'validations' do
    let(:referring_url) { 'http://dp.g.doubleclick.net/apps/domainpark/domainpark.cgi?r=m&fexp=21404&client=dp-domainactive01_email_3ph&channel=domainactive_acq330%2C002362&hl=en&adsafe=medium&type=0&kw=pet%20insurance%20for%20dogs&drid=as-drid-2555559779026318&uiopt=false&q=Pet%2BInsurance%2Bfor%2BDogs&afdt=CvIBChMIpqHOndi9zQIVjDJpCh3nbQTmGAEgBFDw0KABUKHIyQVQzrbbB1DIptAJUN2m0AlQ3qbQCVDH7eoLUMv49AxQ3sK3DlDp35gRULnthBtQutjgJ1Cx2sEsUJmk3DlQlujtOlDPmow7UJ3B3ztQ4eDfO1Cq3v5OUMn5lJUBUOvx7ZcBUNz7n5sBUPGhvp0BULKfueMBUM3a-dMEUJ_i_dYEUOyWiegEUO6y9oYFUJ-RiuEGaPDQoAFxoXQMazUQYMSCARMIwtrQndi9zQIVjYdpCh2cuQcBjQFmC3kPkQGqRBIt9eY0kJEBFN3kLtDqZNMSGQBtOoqQewFaG4GyJFUIclope00y0R-Fu9M&oe=UTF-8&ie=UTF-8&format=p5&ad=a5&adrep=2&num=0&output=caf&domain_name=www.affordableinsurancerates.net&v=3&allwcallad=1&adext=as1%2Csr1%2Cctc1&bsl=8&u_his=2&u_tz=-300&dt=1466669126079&u_w=360&u_h=640&biw=360&bih=559&psw=360&psh=74&frm=0&uio=uv3cs1vp1af3st22sd14sv14sa14sl1sr1cc1-&jsv=14054&rurl=http%3A%2F%2Fwww.affordableinsurancerates.net%2Frelated%2Fpet-insurance-for-dogs.htm%3Fodata%3DM2tMaFdYQUd2cXBpaVd0Y2lWMkNHdz09%26query%3DPet%2BInsurance%2Bfor%2BDogs%26afdToken%3DCvIBChMIpqHOndi9zQIVjDJpCh3nbQTmGAEgBFDw0KABUKHIyQVQzrbbB1DIptAJUN2m0AlQ3qbQCVDH7eoLUMv49AxQ3sK3DlDp35gRULnthBtQutjgJ1Cx2sEsUJmk3DlQlujtOlDPmow7UJ3B3ztQ4eDfO1Cq3v5OUMn5lJUBUOvx7ZcBUNz7n5sBUPGhvp0BULKfueMBUM3a-dMEUJ_i_dYEUOyWiegEUO6y9oYFUJ-RiuEGaPDQoAFxoXQMazUQYMSCARMIwtrQndi9zQIVjYdpCh2cuQcBjQFmC3kPkQGqRBIt9eY0kJEBFN3kLtDqZNMSGQBtOoqQewFaG4GyJFUIclope00y0R-Fu9M&ref=http%3A%2F%2Fdp.g.doubleclick.net%2Fapps%2Fdomainpark%2Fdomainpark.cgi%3Fr%3Dm%26fexp%3D21404%26client%3Ddp-domainactive01_email_3ph%26channel%3Ddomainactive_acq330%252C002362%26hl%3Den%26adsafe%3Dmedium%26type%3D3%26kw%3Daffordable%2520insurance%2520rates%26optimize_terms%3Doff%26terms%3Danimal%2520insurance%252C%2520cat%2520insurance%252C%2520pet%2520health%2520insurance%252C%2520dog%2520health%2520insurance%252C%2520pet%2520insurance%2520for%2520dogs%26drid%3Das-drid-2555559779026318%26uiopt%3Dfalse%26oe' }

    it 'allows long reffering_url' do
      expect { create(:visitor, referring_url: referring_url) }.to_not raise_error
    end

  end

end
