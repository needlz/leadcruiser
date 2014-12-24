require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
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

   		# Check Responses table and return with JSON response
      response = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id).try(:first)
      puts response
      unless response.nil?
        # Update lead
        lead.times_sold = 1
        lead.total_sale_amount = response.price
        lead.update_attributes :status => Lead::SOLD

        return true
      end
   	end

		return false
	end

end