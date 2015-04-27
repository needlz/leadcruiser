require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
require 'data_generators/pets_best_generator'
require 'data_generators/healthy_paws_generator'
require 'data_generators/vet_care_health_generator'
require 'next_client_builder'
require 'data_generator_provider'
require 'workers/send_data_worker.rb'

class AdminsController < ApplicationController
	
	def resend_lead
		lead = Lead.find(params[:format])
		
		if resend_logic(lead)
			redirect_to admin_leads_path, :notice => "Resend success!"
		else
			redirect_to admin_leads_path, :notice => "Resend failure!"
		end
	end

	def resend_logic(lead)
		if lead.status == Lead::SOLD
			return false
		end

		duplicated = duplicated_lead(lead.email, lead.vertical_id)

		if duplicated
      lead.update_attributes(:status => Lead::DUPLICATED)
      return false
   	else
   		SendDataWorker.new.perform(lead.id)

      response_list = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
      if !response_list.nil? && response_list.length != 0
      	# Send email to administrator
        response_id_list = []
        for i in 0..response_list.length - 1
          response_id_list << response_list[i].id
        end
        SendEmailWorker.perform_async(response_id_list, lead.id)

        return true
      end
   	end

		return false
	end

end