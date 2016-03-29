class HomeController < ApplicationController
  def index
    @users = User.all
    render "rewards"
  end
end
