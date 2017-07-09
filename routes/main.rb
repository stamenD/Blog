get '/' do
  @allposts=Post.all
  erb :control
end