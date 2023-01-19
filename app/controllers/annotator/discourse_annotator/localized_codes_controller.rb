class Annotator::DiscourseAnnotator::LocalizedCodesController < Annotator::ApplicationController

  def index
    # p "👉 #{params[:project_id]}"
    codes = DiscourseAnnotator::Code
              .select('discourse_annotator_codes.id, discourse_annotator_localized_codes.path localized_path, discourse_annotator_codes.description')
              .order("LOWER(discourse_annotator_localized_codes.path) ASC")
              .where(project_id: params[:project_id])
              .joins(:localized_codes)
              .where(discourse_annotator_localized_codes: { language_id: DiscourseAnnotator::UserSetting.language_for_user(current_user).id })

    codes = codes.where("discourse_annotator_localized_codes.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?

    respond_to do |format|
      format.json { render json: codes.to_json(fields: %i[code_id localized_path description]) }
    end
  end

  def mergeable
    list
  end

  def autosuggest_codes
    list
  end


  private

  def list
    codes = DiscourseAnnotator::Code
              .select('discourse_annotator_codes.id, users.username username, discourse_annotator_localized_codes.path localized_path')
              .order("LOWER(discourse_annotator_localized_codes.path) ASC")
              .where(project_id: params[:project_id])
              .joins(:creator)
              .joins(:localized_codes)
              .group(%w[discourse_annotator_codes.id users.username discourse_annotator_localized_codes.path])

    # Removed. See: https://github.com/edgeryders/discourse-annotator/issues/200
    # .where(discourse_annotator_localized_codes: {language_id: DiscourseAnnotator::UserSetting.language_for_user(current_user).id})

    codes = codes.where.not(id: params[:code_id]) if params[:code_id].present?
    # codes = codes.where("' ' || discourse_annotator_localized_codes.path ILIKE ?", "% #{params[:q].split.join('%')}%") if params[:q].present?
    codes = codes.where("discourse_annotator_localized_codes.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?
    respond_to do |format|
      format.json {
        render json: codes.map { |c|
          { id: c.id, localized_path: "#{c.localized_path} (by #{c.username})" }
        }.to_json
      }
    end
  end

end




# settings = current_user.discourse_annotator_settings

# if settings&.discourse_tag.present?
#   code_ids = DiscourseAnnotator::Annotation.select('DISTINCT code_id')
#                  .where(topic_id: current_user.discourse_annotator_settings.discourse_tag.topics)
#   codes = codes.where(id: code_ids)
# end

# if settings&.propose_codes_from_users.present?
#   user_ids = settings&.propose_codes_from_users.split.map { |n| User.find_by(username: n)&.id }.compact
#   user_ids << current_user.id
#   codes = codes.where(creator_id: user_ids)
# elsif settings&.discourse_tag.blank?
#   codes = codes.where(creator_id: current_user.id)
# end

# codes = codes.where("' ' || discourse_annotator_localized_codes.path ILIKE ?", "% #{params[:q].split.join('%')}%") if params[:q].present?