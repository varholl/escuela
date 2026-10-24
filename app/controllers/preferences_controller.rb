# The two permissions a student can give and take back: remembering what she
# reads, so courses can be suggested, and writing to her about new ones.
class PreferencesController < ApplicationController
  allow_gated_access
  before_action :require_authentication

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    @user.update!(params.expect(user: %i[ remember_reading wants_news ]))

    redirect_to edit_preferences_path, notice: t("preferences.updated"), status: :see_other
  end
end
