class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    # User must be logged in to access this action
    render plain: 'Succes'
  end
end