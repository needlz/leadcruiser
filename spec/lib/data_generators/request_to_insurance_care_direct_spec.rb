require 'rails_helper'
require 'data_generators/request_to_insurance_care_direct'

RSpec.describe RequestToInsuranceCareDirect, type: :request do
  let(:health_match_up) { create(:site, domain: 'healthmatchup.com') }
  let(:get_health) { create(:site, domain: 'gethealthcare.co') }
  let(:health_insurance_lead_med_supp) { create(:health_insurance_lead,
                                                lead: lead,
                                                boberdoo_type: RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE) }
  let(:health_insurance_lead_health) { create(:health_insurance_lead,
                                              lead: lead,
                                              boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE, tsrc: '1') }
  let(:client) { create(:clients_vertical, service_url: 'http://myhealthlineone.com/API/LeadReceiver.api', request_type: 'XML') }

  let(:good_response) {
    <<-xml
    <?xml version="1.0" encoding="utf-8"?>
<PostResponse xmlns="http://www.icdapi.com/">
    <isValidPost>True</isValidPost>
    <ResponseType>No_Error</ResponseType>
    <ResponseDetails>Lead received at 2017-05-08 05:13:28</ResponseDetails>
    <LeadIdentifier>2733280</LeadIdentifier>
    <VendorAccountAssigned>long</VendorAccountAssigned>
    <PendingQCReview>False</PendingQCReview>
</PostResponse>
    xml
  }

  let(:bad_response) {
    <<-xml
    <?xml version="1.0" encoding="utf-8"?>
      <PostResponse xmlns="http://www.icdapi.com/">
    <isValidPost>False</isValidPost>
    <ResponseType>Data_Errors</ResponseType>
    <ResponseDetails>Value(s) for DayPhone missing from post or invalid.</ResponseDetails>
    <LeadIdentifier></LeadIdentifier>
    <VendorAccountAssigned>long</VendorAccountAssigned>
    <PendingQCReview>False</PendingQCReview>
</PostResponse>
    xml
  }

  describe '#success?' do
    let(:exclusive) { true }
    let(:lead) { create(:lead, site: health_match_up) }

    before do
      stub_request(:post, "http://myhealthlineone.com/API/LeadReceiver.api").
        with(:body => "LeadId=1&SourceID=481&SourceCode=RickTest&Passphrase=fcunytv51l30v1pujdkog6u3e&FirstName=John&LastName=Doe&Address=&City=&State=&Zip=10001&Email=test%40example.com&DayPhone=2-12-22&EveningPhone=&DateOfBirth=&Address2=&IPAddress=127.1.1.1&Source=source&LandingPage=http%3A%2F%2Fgethealthcare.co&ExistingConditions=&Gender=&HeightFT=&HeightIN=&Weight=&Smoker=",
             :headers => {'Content-Type'=>'application/xml'}).
        to_return(:status => 200, :body => response, :headers => {'Content-Type'=>'application/xml'})
    end

    context 'when response is successful' do
      before do
        health_insurance_lead_health
      end

      let(:response) { good_response }

      it 'returns true' do
        request = RequestToInsuranceCareDirect.new(lead)
        request.do_request(exclusive, client)
        expect(request.success?).to be_truthy
      end
    end # when response is successful

    context 'when response is unsuccessful' do
      before do
        health_insurance_lead_health
      end

      let(:response) { bad_response }

      it 'returns false' do
        request = RequestToInsuranceCareDirect.new(lead)
        request.do_request(exclusive, client)
        expect(request.success?).to be_falsey
      end
    end # when response is unsuccessful
  end # #success?
end
