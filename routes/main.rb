require_relative "workWithPosts"

get '/' do
  @allposts=Post.all
  erb :control
end