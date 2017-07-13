require_relative "account"
require_relative "post"

helpers do
  def findLanguage
    if !session[:language] then  @env["HTTP_ACCEPT_LANGUAGE"][0,2] else session[:language].to_sym end 
  end
end

get '/' do
	# session.clear
  @language = findLanguage
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

post "/tag/*" do
  if params['splat'][0] 
    session[:tag] = params['splat'][0] 
  else 
    session[:tag] = false
  end
  redirect '/'
end

post "/sort/*" do
  session[:sort] = params['splat'][0]
  redirect '/'
end

post "/language/*" do
  session[:language] = params['splat'][0]
  redirect '/'
end