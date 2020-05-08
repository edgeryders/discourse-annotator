module UserAnnotatable
  extend ActiveSupport::Concern
  included do

    has_one :annotator_store_settings, class_name: 'AnnotatorStore::UserSetting', foreign_key: 'discourse_user_id'


    def self.annotators
      annotator_group = Group.find_by(name: 'annotator')
      joins(:group_users).where(group_users: {group_id: annotator_group.id})
    end



  end
end