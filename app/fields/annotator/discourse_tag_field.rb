class Annotator::DiscourseTagField < Administrate::Field::BelongsTo


  def associated_resource_options
    [['none (shows your own codes)', nil]] + candidate_resources.map do |resource|
      [display_candidate_resource(resource), resource.send(primary_key)]
    end
  end


end