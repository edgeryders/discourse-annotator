class Annotator::AnnotatorStore::LocalizedTagsController < Annotator::ApplicationController


  def search
    tags = AnnotatorStore::Tag.joins(:localized_tags)
               .select('annotator_store_localized_tags.path')
               .where(creator_id: current_user.id)
               .where(annotator_store_localized_tags: {language_id: AnnotatorStore::UserSetting.language_for_user(current_user).id})
               .order("LOWER(path) ASC")
    tags = tags.where("annotator_store_localized_tags.path ILIKE ?", "%#{params[:q].split.join('%')}%") if params[:q].present?

    respond_to do |format|
      format.json {render json: tags.pluck(:path).to_json}
    end
  end


end