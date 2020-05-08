require 'administrate/base_dashboard'

class TagDashboard < Administrate::BaseDashboard


  # Overwrite this method to customize how tags are displayed
  # across all pages of the admin dashboard.
  def display_resource(tag)
    tag.name
  end

end
