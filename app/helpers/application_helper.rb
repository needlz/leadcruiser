module ApplicationHelper
	def UTCToPST(datetime)
		datetime.nil? ? "": datetime.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M:%S PST")
	end
end
