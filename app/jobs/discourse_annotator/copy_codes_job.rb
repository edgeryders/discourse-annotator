require 'activejob-status'

module DiscourseAnnotator
  class CopyCodesJob < ActiveJob::Base
    queue_as :default
    self.queue_adapter = :sidekiq

    include ActiveJob::Status

    def perform(code_ids:, project_id:, include_descendants: false)
      codes = include_descendants ?
                Code.top_level_codes(code_ids) :
                Code.where(id: code_ids)

      progress.total = codes.length

      codes.each do |code|
        code.create_copy(project_id: project_id, include_descendants: include_descendants)
        progress.increment
      end
    end

  end
end
