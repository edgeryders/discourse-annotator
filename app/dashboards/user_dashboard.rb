require 'administrate/base_dashboard'

class UserDashboard < Administrate::BaseDashboard

  def display_resource(user)
    user.username
  end

end
