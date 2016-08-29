# == Schema Information
#
# Table name: health_insurance_leads
#
#  id                             :integer          not null, primary key
#  lead_id                        :integer
#  boberdoo_type                  :string
#  match_with_partner_id          :text
#  redirect_url                   :text
#  src                            :text
#  sub_id                         :string
#  pub_id                         :string
#  optout                         :string
#  imbx                           :string
#  ref                            :string
#  user_agent                     :string
#  tsrc                           :string
#  landing_page                   :text
#  skip_xsl                       :string
#  test_lead                      :string
#  fpl                            :string
#  age                            :integer
#  height_feet                    :integer
#  height_inches                  :integer
#  weight                         :integer
#  tobacco_use                    :string
#  preexisting_conditions         :string
#  household_income               :integer
#  household_size                 :integer
#  qualifying_life_event          :string
#  spouse_gender                  :string
#  spouse_age                     :integer
#  spouse_height_feet             :integer
#  spouse_height_inches           :integer
#  spouse_weight                  :integer
#  spouse_tobacco_use             :string
#  spouse_preexisting_conditions  :string
#  child_1_gender                 :string
#  child_1_age                    :integer
#  child_1_height_feet            :integer
#  child_1_height_inches          :integer
#  child_1_weight                 :integer
#  child_1_tobacco_use            :string
#  child_1_preexisting_conditions :string
#  child_2_gender                 :string
#  child_2_age                    :integer
#  child_2_height_feet            :integer
#  child_2_height_inches          :integer
#  child_2_weight                 :integer
#  child_2_tobacco_use            :string
#  child_2_preexisting_conditions :string
#  child_3_gender                 :string
#  child_3_age                    :integer
#  child_3_height_feet            :integer
#  child_3_height_inches          :integer
#  child_3_weight                 :integer
#  child_3_tobacco_use            :string
#  child_3_preexisting_conditions :string
#  child_4_gender                 :string
#  child_4_age                    :integer
#  child_4_height_feet            :integer
#  child_4_height_inches          :integer
#  child_4_weight                 :integer
#  child_4_tobacco_use            :string
#  child_4_preexisting_conditions :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

class HealthInsuranceLead < ActiveRecord::Base

  validates_presence_of  :boberdoo_type, :src, :landing_page, :age

  belongs_to :lead

  def lead_type
    case boberdoo_type
      when '21'
        'Health Insurance'
      when '23'
        'Medicare Supplement'
    end
  end

end
