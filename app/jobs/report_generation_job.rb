class ReportGenerationJob < ActiveJob::Base
  queue_as :high

  def perform(params, filename)
    sheet = Reporting::LeadRows.new(params, filename)
    sheet.save_to_file
  end
end
