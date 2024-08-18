class HomeController < ApplicationController
  def home
    @articles = Feed.last(3)
  end
end
