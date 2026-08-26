# The institutional video on the home page. Public on purpose -- it is the
# school introducing itself -- but still served from the private bucket through
# a signed link rather than by making the object world-readable.
class PageVideosController < ApplicationController
  include VideoDelivery

  def show
    page = Page.for(params[:id])

    return head :not_found if page.nil?

    deliver_video page.feature_video
  end
end
