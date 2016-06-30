class AddGethealthcareCrawlerRecipientsCommaSeparatedToEditableConfigurations < ActiveRecord::Migration
  def change
    add_column :editable_configurations, :gethealthcare_notified_recipients_comma_separated, :text
  end
end
