require 'data_generators/request_to_pet_premium'
require 'data_generators/request_to_pet_first'
require 'data_generators/request_to_pets_best'
require 'data_generators/request_to_healthy_paws'
require 'data_generators/request_to_vet_care_health'
require 'next_client_builder'
require 'request_to_client_generator'
require 'workers/send_pet_data_worker.rb'

class AdminsController < ApplicationController

  def restart_server
    redirect_to(root_path)
    RestartServer.perform
  end

	def resend_lead
		lead = Lead.find(params[:format])
		
		if resend_logic(lead)
			redirect_to admin_leads_path, :notice => "Resend success!"
		else
			redirect_to admin_leads_path, :notice => "Resend failure!"
		end
	end

	def resend_logic(lead)
		return false if lead.sold?

    filter_txt = [lead.first_name, lead.last_name, lead.email, lead.details_pets.try(:first).try(:pet_name)].join(' ')

		if LeadValidation.duplicated_lead(lead.email, lead.vertical_id, lead.site_id)
      lead.update_attributes(:status => Lead::DUPLICATED)
      return false

    elsif LeadValidation.blocked(lead)
      lead.update_attributes(:status => Lead::BLOCKED, :disposition => Lead::IP_BLOCKED)
      return false

    elsif lead.first_name == Lead::TEST_TERM && lead.last_name == Lead::TEST_TERM
      lead.update_attributes(:status => Lead::BLOCKED, :disposition => Lead::TEST_NO_SALE)
      return false

    elsif Obscenity.profane?(filter_txt)
      lead.update_attributes(:status => Lead::BLOCKED, :disposition => Lead::PROFANITY)
      return false

   	else
      if lead.first_name.downcase == "erik" && lead.last_name.downcase == "needham"
        lead.update_attribute(:disposition, Lead::TEST_SALE)
      end

      if lead.health_insurance?
        ForwardHealthInsuranceLead.perform(lead)
      elsif lead.pet_insurance?
        SendPetDataWorker.new.perform(lead.id)
      end

      response_list = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
      return true if !response_list.nil? && response_list.length != 0
   	end

		return false
	end

end