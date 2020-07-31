class Annotator::AnnotatorStore::LocalizedTagsController < Annotator::ApplicationController


  def index
    tags = AnnotatorStore::Tag.joins(:localized_tags)
               .select('annotator_store_tags.id, annotator_store_localized_tags.path localized_path')
               .order("LOWER(annotator_store_localized_tags.path) ASC")
               .where(annotator_store_localized_tags: {language_id: AnnotatorStore::UserSetting.language_for_user(current_user).id})

    tags = if current_user.annotator_store_settings&.discourse_tag.present?
             code_ids = AnnotatorStore::Annotation.select('DISTINCT tag_id')
                            .where(topic_id: current_user.annotator_store_settings.discourse_tag.topics)
             tags.where(id: code_ids)
           else
             tags.where(creator_id: current_user.id)
           end



    tags = tags.where("annotator_store_localized_tags.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?

    respond_to do |format|
      format.json {render json: tags.to_json(fields: %i[tag_id localized_path])}
    end
  end


  def mergeable
    codes = AnnotatorStore::Tag.joins(:localized_tags).joins(:creator)
                .select('annotator_store_tags.id, users.username username, annotator_store_localized_tags.path localized_path')
                .order("LOWER(annotator_store_localized_tags.path) ASC")
                .where.not(id: params[:code_id])
                .where(annotator_store_localized_tags: {language_id: AnnotatorStore::UserSetting.language_for_user(current_user).id})
    codes = codes.where("annotator_store_localized_tags.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?
    respond_to do |format|
      format.json {
        render json: codes.map {|c|
          {id: c.id, localized_path: "#{c.localized_path} (by #{c.username})"}
        }.to_json
      }
    end
  end


end

