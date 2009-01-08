xm.item do
  xm.title _("%{title} posted by %{user} @ %{date}") % {:title => h(post.respond_to?(:topic_title) ? post.topic_title : post.topic.title), :user => h(post.user.login), :date => post.created_at.rfc822}
  xm.description post.body_html
  xm.pubDate post.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, post.forum_id.to_s, post.topic_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{post.user.login}"
  xm.link forum_topic_url(post.forum_id, post.topic_id)
end
