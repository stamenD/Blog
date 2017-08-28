require_relative "account"
require_relative "post"

helpers do
  def findLanguage
    # if !session[:language] then  @env["HTTP_ACCEPT_LANGUAGE"][0,2] else session[:language].to_sym end 
    if !session[:language]
      session[:language] = :en
      :en
   else 
      session[:language].to_sym 
   end 
  end
end

not_found do
  "Does not exist this page!"
end

get '/' do
  status session[:status] if session[:status] 
  status session[:status] = false

	# session.clear
  @language = findLanguage
  @sortBy = if !session[:sort] then :id else session[:sort].to_sym end
  @showOnly = session[:tag]
  @allposts = if !@showOnly || @showOnly=="" 
    Post.where(language: @language).sort_by &@sortBy
  else 
    Post.tagged_with(@showOnly).where(language: @language).sort_by &@sortBy
  end
  @allposts = @allposts.reverse if session[:reverse]

  Tag.clear_unused
  erb :main
end

post "/tag/*" do
  if params['splat'][0] 
    session[:tag] = params['splat'][0] 
  else 
    session[:tag] = false
  end
  session[:reverse] = if (session[:reverse] == false ||  session[:reverse] == true) then !session[:reverse] else false end
  redirect '/'
end

post "/sort/*" do
  session[:sort] = params['splat'][0]
  session[:reverse] = if (session[:reverse] == false ||  session[:reverse] == true) then !session[:reverse] else false end
  redirect '/'
end

post "/language/*" do
  session[:language] = params['splat'][0]
  redirect '/'
end