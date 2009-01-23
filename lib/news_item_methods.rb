module NewsItemMethods

  protected

  def get_news_item
    @news_item = NewsItem.find_by_url_key(params[:id]) || NewsItem.find(params[:id])
  end

end