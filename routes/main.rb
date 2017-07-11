require_relative "account"
require_relative "post"


get '/' do
  @sortBy = if !session[:sort] then :id else session[:sort].to_sym end
  @showOnly = session[:tag]
  @allposts = if !@showOnly || @showOnly=="" 
    Post.all.sort_by &@sortBy
  else 
    Post.tagged_with(@showOnly).sort_by &@sortBy
  end
  
  Tag.clear_unused
  erb :main
end

get "/tag/*" do
  if params['splat'][0] 
    session[:tag] = params['splat'][0] 
  else 
    session[:tag] = false
  end
  redirect '/'
end

get "/sort/*" do
  session[:sort] = params['splat'][0]
  redirect '/'
end