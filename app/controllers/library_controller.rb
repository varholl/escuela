# What a student sees of her own shelf.
class LibraryController < ApplicationController
  # Authentication is the stronger door, and its redirect is the useful one:
  # someone coming back to their shelf should get the sign-in screen.
  allow_gated_access
  before_action :require_authentication

  def show
    @courses = Current.user.enrolled_courses.ordered
  end
end
