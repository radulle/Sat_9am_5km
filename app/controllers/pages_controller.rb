# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :validate_page

  def show
    render template: "pages/#{page_name}"
  end

  private

  def page_name
    @page_name ||= params[:page].presence || 'index'
  end

  def validate_page
    path = Rails.root.join, 'app/views/pages', "#{page_name}.#{request.format.to_sym}.erb"
    render file: 'public/404.html', status: :not_found unless File.exist?(path)
  end
end
