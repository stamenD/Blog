require_relative "workWithPosts"

get '/' do
  @allposts=Post.all
  Tag.clear_unused
  erb :control
end