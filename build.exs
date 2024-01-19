posts = Blog.all_posts()

File.rm_rf!("./static")
File.mkdir!("./static")
File.cp_r!("./content/assets", "./static/assets")
File.cp("./content/assets/favicon.ico", "./static/favicon.ico")

# load site template
# for each post, write to static

File.write!("./static/assets/highlight.css", Makeup.stylesheet(:monokai_style, "makeup"))

html = Blog.Index.exec([posts: posts])
File.write!("./static/index.html", html)

for post <- posts do
  html = Blog.Post.exec(Map.from_struct(post))

  File.write!("./static/#{post.filename}.html", html)
end
