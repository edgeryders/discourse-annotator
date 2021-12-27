require 'administrate/base_dashboard'

class TagDashboard < Administrate::BaseDashboard

  def display_resource(tag)
    tag.name
  end

end
