require_relative "workWithPosts"
require_relative "createAccount"

get '/' do
  @allposts=Post.all
  Tag.clear_unused
  erb :main
end