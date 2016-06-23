class AddLeadForwardingDelaySecondsToClientsVerticals < ActiveRecord::Migration
  def change
    add_column :clients_verticals, :lead_forwarding_delay_seconds, :integer, default: 0
  end
end
