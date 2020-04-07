module UserAnnotatable
  extend ActiveSupport::Concern
  included do


    def self.annotators
      annotator_group = Group.find_by(name: 'annotator')
      joins(:group_users).where(group_users: {group_id: annotator_group.id})
    end


  end
end