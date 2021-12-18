class Annotator::DiscourseAnnotator::LocalizedTagsController < Annotator::ApplicationController


  def index
    settings = current_user.discourse_annotator_settings

    tags = DiscourseAnnotator::Tag
               .select('discourse_annotator_tags.id, discourse_annotator_localized_tags.path localized_path')
               .order("LOWER(discourse_annotator_localized_tags.path) ASC")
               .joins(:localized_tags)
               .where(discourse_annotator_localized_tags: {language_id: DiscourseAnnotator::UserSetting.language_for_user(current_user).id})

    if settings&.discourse_tag.present?
      code_ids = DiscourseAnnotator::Annotation.select('DISTINCT tag_id')
                     .where(topic_id: current_user.discourse_annotator_settings.discourse_tag.topics)
      tags = tags.where(id: code_ids)
    end

    if settings&.propose_codes_from_users.present?
      user_ids = settings&.propose_codes_from_users.split.map { |n| User.find_by(username: n)&.id }.compact
      user_ids << current_user.id
      tags = tags.where(creator_id: user_ids)
    elsif settings&.discourse_tag.blank?
      tags = tags.where(creator_id: current_user.id)
    end


    # tags = tags.where("' ' || discourse_annotator_localized_tags.path ILIKE ?", "% #{params[:q].split.join('%')}%") if params[:q].present?
    tags = tags.where("discourse_annotator_localized_tags.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?

    respond_to do |format|
      format.json { render json: tags.to_json(fields: %i[tag_id localized_path]) }
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
    codes = DiscourseAnnotator::Tag
                .joins(:creator)
                .joins(:localized_tags)
                .select('discourse_annotator_tags.id, users.username username, discourse_annotator_localized_tags.path localized_path')
                .order("LOWER(discourse_annotator_localized_tags.path) ASC")
                .group(%w[discourse_annotator_tags.id users.username discourse_annotator_localized_tags.path])

    # Removed. See: https://github.com/edgeryders/discourse-annotator/issues/200
    # .where(discourse_annotator_localized_tags: {language_id: DiscourseAnnotator::UserSetting.language_for_user(current_user).id})

    codes = codes.where.not(id: params[:code_id]) if params[:code_id].present?
    # codes = codes.where("' ' || discourse_annotator_localized_tags.path ILIKE ?", "% #{params[:q].split.join('%')}%") if params[:q].present?
    codes = codes.where("discourse_annotator_localized_tags.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?
    respond_to do |format|
      format.json {
        render json: codes.map { |c|
          {id: c.id, localized_path: "#{c.localized_path} (by #{c.username})"}
        }.to_json
      }
    end
  end


end

