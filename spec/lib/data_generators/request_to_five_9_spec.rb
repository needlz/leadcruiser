require 'rails_helper'

describe RequestToFive9 do

  before do
    create(:vertical, name: Vertical::HEALTH_INSURANCE)
  end

  let(:client) { ClientsGenerator.five9.client }
  let!(:lead) { create(:lead) }
  let!(:health_lead) { create(:health_insurance_lead, lead: lead) }
  let(:request) { result = RequestToFive9.new(lead); result.client = client; result }

  describe '#succes?' do

    context 'on successful response' do
      before do
        stub_request(:post, request.request_url).
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200,
                    :body => "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"><HTML><HEAD><title>WebToCampaign Response</title><META http-equiv=\"Content-Type\"   content=\"text/html\"></HEAD><BODY><h1>Inputs:</h1><FORM><TABLE><TR><TD>street:</TD><TD><INPUT readonly id=\"street\" name=\"street\" value=\"\" size=\"0\"></TD></TR><TR><TD>leadId:</TD><TD><INPUT readonly id=\"leadId\" name=\"leadId\" value=\"223\" size=\"3\"></TD></TR><TR><TD>city:</TD><TD><INPUT readonly id=\"city\" name=\"city\" value=\"\" size=\"0\"></TD></TR><TR><TD>first_name:</TD><TD><INPUT readonly id=\"first_name\" name=\"first_name\" value=\"test\" size=\"4\"></TD></TR><TR><TD>number1:</TD><TD><INPUT readonly id=\"number1\" name=\"number1\" value=\"3035551987\" size=\"10\"></TD></TR><TR><TD>F9list:</TD><TD><INPUT readonly id=\"F9list\" name=\"F9list\" value=\"LeadcruiserPostedLeadsNEW\" size=\"25\"></TD></TR><TR><TD>last_name:</TD><TD><INPUT readonly id=\"last_name\" name=\"last_name\" value=\"test\" size=\"4\"></TD></TR><TR><TD>F9domain:</TD><TD><INPUT readonly id=\"F9domain\" name=\"F9domain\" value=\"Promise Insurance\" size=\"17\"></TD></TR><TR><TD>state:</TD><TD><INPUT readonly id=\"state\" name=\"state\" value=\"\" size=\"0\"></TD></TR><TR><TD>zip:</TD><TD><INPUT readonly id=\"zip\" name=\"zip\" value=\"80210\" size=\"5\"></TD></TR></TABLE><BR><h1>Result:</h1><TABLE><TR><TD>Error Code:</TD><TD><INPUT readonly id=\"F9errCode\" name=\"F9errCode\" value=\"0\" size=\"10\"></TD></TR><TR><TD>Error Decription:</TD><TD><INPUT readonly id=\"F9errDesc\" name=\"F9errDesc\" value=\"The request was successfully processed\" size=\"38\"></TD></TR></TABLE></FORM></BODY></HTML>\r\n",
                    :headers => {})
      end

      it 'returns true' do
        request.do_request(false, client)
        expect(request).to be_success
      end
    end

    context 'on fail response' do
      before do
        stub_request(:post, request.request_url).
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200,
                    :body => "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"><HTML><HEAD><title>WebToCampaign Response</title><META http-equiv=\"Content-Type\"   content=\"text/html\"></HEAD><BODY><h1>Inputs:</h1><FORM><TABLE><TR><TD>street:</TD><TD><INPUT readonly id=\"street\" name=\"street\" value=\"some address\" size=\"12\"></TD></TR><TR><TD>leadId:</TD><TD><INPUT readonly id=\"leadId\" name=\"leadId\" value=\"1643\" size=\"4\"></TD></TR><TR><TD>city:</TD><TD><INPUT readonly id=\"city\" name=\"city\" value=\"Newton Falls\" size=\"12\"></TD></TR><TR><TD>first_name:</TD><TD><INPUT readonly id=\"first_name\" name=\"first_name\" value=\"test1\" size=\"5\"></TD></TR><TR><TD>number1:</TD><TD><INPUT readonly id=\"number1\" name=\"number1\" value=\"4157777889\" size=\"10\"></TD></TR><TR><TD>F9list:</TD><TD><INPUT readonly id=\"F9list\" name=\"F9list\" value=\"LeadcruiserPostedLeadsNEW\" size=\"25\"></TD></TR><TR><TD>last_name:</TD><TD><INPUT readonly id=\"last_name\" name=\"last_name\" value=\"test\" size=\"4\"></TD></TR><TR><TD>F9domain:</TD><TD><INPUT readonly id=\"F9domain\" name=\"F9domain\" value=\"Promise Insurance\" size=\"17\"></TD></TR><TR><TD>state:</TD><TD><INPUT readonly id=\"state\" name=\"state\" value=\"OH\" size=\"2\"></TD></TR><TR><TD>zip:</TD><TD><INPUT readonly id=\"zip\" name=\"zip\" value=\"44444\" size=\"5\"></TD></TR></TABLE><BR><h1>Result:</h1><TABLE><TR><TD>Error Code:</TD><TD><INPUT readonly id=\"F9errCode\" name=\"F9errCode\" value=\"708\" size=\"10\"></TD></TR><TR><TD>Error Decription:</TD><TD><INPUT readonly id=\"F9errDesc\" name=\"F9errDesc\" value=\"More than one record matches specified criteria\" size=\"47\"></TD></TR></TABLE></FORM></BODY></HTML>\r\n",
                    :headers => {})
      end

      it 'returns false' do
        request.do_request(false, client)
        expect(request).to_not be_success
        expect(request.rejection_reason).to eq "More than one record matches specified criteria"
      end
    end

  end

end
