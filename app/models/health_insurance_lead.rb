# == Schema Information
#
# Table name: health_insurance_leads
#
#  id                             :integer          not null, primary key
#  lead_id                        :integer
#  boberdoo_type                  :string(255)
#  match_with_partner_id          :text
#  redirect_url                   :text
#  src                            :text
#  sub_id                         :string(255)
#  pub_id                         :string(255)
#  optout                         :string(255)
#  imbx                           :string(255)
#  ref                            :string(255)
#  user_agent                     :string(255)
#  tsrc                           :string(255)
#  fpl                            :string(255)
#  age                            :integer
#  height_feet                    :integer
#  height_inches                  :string(255)
#  weight                         :string(255)
#  tobacco_use                    :string(255)
#  preexisting_conditions         :string(255)
#  household_income               :integer
#  household_size                 :integer
#  qualifying_life_event          :string(255)
#  spouse_gender                  :string(255)
#  spouse_age                     :integer
#  spouse_height_feet             :integer
#  spouse_height_inches           :integer
#  spouse_weight                  :integer
#  spouse_tobacco_use             :boolean
#  spouse_preexisting_conditions  :boolean
#  child_1_gender                 :string(255)
#  child_1_age                    :integer
#  child_1_height_feet            :integer
#  child_1_height_inches          :integer
#  child_1_weight                 :integer
#  child_1_tobacco_use            :string(255)
#  child_1_preexisting_conditions :string(255)
#  child_2_gender                 :string(255)
#  child_2_age                    :integer
#  child_2_height_feet            :integer
#  child_2_height_inches          :integer
#  child_2_weight                 :integer
#  child_2_tobacco_use            :string(255)
#  child_2_preexisting_conditions :string(255)
#  child_3_gender                 :string(255)
#  child_3_age                    :integer
#  child_3_height_feet            :integer
#  child_3_height_inches          :integer
#  child_3_weight                 :integer
#  child_3_tobacco_use            :string(255)
#  child_3_preexisting_conditions :string(255)
#  child_4_gender                 :string(255)
#  child_4_age                    :integer
#  child_4_height_feet            :integer
#  child_4_height_inches          :integer
#  child_4_weight                 :integer
#  child_4_tobacco_use            :string(255)
#  child_4_preexisting_conditions :string(255)
#

class HealthInsuranceLead < ActiveRecord::Base

  validates_presence_of  :boberdoo_type, :src, :landing_page, :age

  belongs_to :lead

end
