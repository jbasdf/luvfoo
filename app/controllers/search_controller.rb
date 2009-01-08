class SearchController < ApplicationController
  
  include SearchHelper
    
  def index
    @query = params[:q] 
    return nil if !@query || @query == '*'

    query = "#{search_field}:(#{@query})"
    @selected_tab = params[:tab] || 'all'

    if @selected_tab == 'members'
      @results = User.find_by_solr(query, :limit => @per_page).results
    elsif @selected_tab == 'groups'
      @results = Group.find_by_solr(query, :limit => @per_page).results
    elsif @selected_tab == 'pages'
      @results = ContentPage.find_by_solr(query, :limit => @per_page).results
    elsif @selected_tab == 'photos'
      @results = Photo.find_by_solr(query, :limit => @per_page).results
    elsif @selected_tab == 'news'
      @results = NewsItem.find_by_solr(query + ' AND (newsable_type:Group)', :limit => @per_page).results
    elsif @selected_tab == 'blogs'
      @results = NewsItem.find_by_solr(query + ' AND (newsable_type:User)', :limit => @per_page).results
    elsif @selected_tab == 'stories'
      @results = NewsItem.find_by_solr(query + ' AND (newsable_type:Widget)', :limit => @per_page).results
    else
      @results = ContentPage.multi_solr_search(query, :limit => @per_page, :models => [User, Group, ContentPage, Photo, NewsItem]).results
    end
    flash[:notice] = @results.empty? ? _('Your search did not match any items on the website.') : nil
  end
  
end
