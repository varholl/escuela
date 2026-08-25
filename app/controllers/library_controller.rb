# What a student sees of her own shelf.
class LibraryController < ApplicationController
  before_action :require_authentication

  def show
    @courses = Current.user.enrolled_courses.ordered
  end
end
