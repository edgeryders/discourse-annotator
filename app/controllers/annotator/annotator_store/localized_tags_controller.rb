class Annotator::AnnotatorStore::LocalizedTagsController < Annotator::ApplicationController


  def index
    tags = AnnotatorStore::Tag.joins(:localized_tags)
               .select('annotator_store_tags.id, annotator_store_localized_tags.path localized_path')
               .where(creator_id: current_user.id)
               .where(annotator_store_localized_tags: {language_id: AnnotatorStore::UserSetting.language_for_user(current_user).id})
               .order("LOWER(annotator_store_localized_tags.path) ASC")
    tags = tags.where("annotator_store_localized_tags.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?

    respond_to do |format|
      format.json {
         # render json: tags.map {|t| {tag_id: t.id, path: t.localized_path} }
         render json: tags.to_json(fields: %i[tag_id localized_path])
      }
    end
  end


end