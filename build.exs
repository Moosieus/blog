Calendar.put_time_zone_database(Tz.TimeZoneDatabase)

today = DateTime.now!("America/New_York", Tz.TimeZoneDatabase)

posts = Blog.all_posts()

File.rm_rf!("./static")
File.mkdir!("./static")
File.cp_r!("./content/assets", "./static/assets")
File.write!("./static/assets/highlight.css", Makeup.stylesheet(:monokai_style, "makeup"))

# write index file
post_list = Blog.Index.exec([posts: posts])

index_page = Blog.Layout.exec([
  title: "Moosieus' Stuff n' Things",
  description: "An index of all my blogs and musings.",
  copyright_date: today.year,
  content: post_list
])

File.write!("./static/index.html", index_page)

# write posts
for post <- posts do
  content = Blog.Post.exec([post: post])
  full_page = Blog.Layout.exec([
    title: post.title,
    description: post.description,
    copyright_date: today.year,
    content: content,
    header_tags: @date_script,
  ])
  File.write!("./static/#{post.filename}.html", full_page)
end
