module SearchHelper

  def tab name  
    lname = name.downcase
    if lname == @selected_tab
      return '<span class="tab_selected">' + _(name) + '</span>'
    else
      return link_to(_(name), '/search?q=' + h(@query) + '&tab=' + lname, :class=>'tab')
    end
  end

  def search_field
    if !logged_in?
      return 'content_p'
    elsif is_admin?
      return 'content_a'
    else
      return 'content_u'
    end
  end

end