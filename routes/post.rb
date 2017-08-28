get "/createPost" do
  @language = findLanguage
  if session[:loginUser] && session[:loginUser].isAdmin == 1
    erb :createPost
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end
end 

get "/posts/:readPost" do
  if Post.find_by_id(params[:readPost])
    @language = findLanguage
    @receiveID = params[:readPost]
    erb :readPost
  else 
    flash[:error] = "Не съществува тази страница"
    session[:status] = 401
    redirect '/'
  end
end 

get "/editPost/*" do
  @language = findLanguage
  if session[:loginUser] && session[:loginUser].isAdmin == 1
    @receiveID = params['splat'][0].to_i
    unless Post.find_by_id(@receiveID)
      flash[:error] = "Не съществува тази страница"
      redirect '/'   
    end     
    erb :editPost
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end
end 

get "/editComment/*" do
  @language = findLanguage
  if session[:loginUser]  &&
    (session[:loginUser].isAdmin==1 || 
    (session[:loginUser].comments.find_by_id params['splat'][0].to_i)) 
    @receiveID = params['splat'][0].to_i
    unless Comment.find_by_id(@receiveID)
      flash[:error] = "Не съществува тази страница"
      redirect '/'   
    end    
    erb :editComment
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end
end 

post "/changePostStatus/*" do 
  @id = params['splat'][0].to_i
  o = Post.find_by_id(@id)
  o.changeStutus
  o.save
  redirect '/'
end

post "/deletePost/*" do
  @id2 = params['splat'][0].to_i
  Post.destroy(@id2)
  redirect '/'
end

post "/deleteComment/*" do
  @id2 = params['splat'][0].to_i
  Comment.destroy(@id2)
  redirect '/'
end

post "/upload" do 
  user = session[:loginUser]
  newPost = Post.create subject: params[:subject], theme:params[:theme] , published: DateTime.now ,isActive: 1
  if params['pic']
    extension = params['pic'][:filename].split('.')[-1]
    imageName = newPost.id.to_s + '.' + extension
    imagePath = 'public/' + imageName    
    File.open(imagePath, "wb") do |f|
      f.write(params['pic'][:tempfile].read)
    end
  else
    imageName = "default.gif"
  end
    newPost.language = session[:language]
    newPost.imagePath = imageName
    newPost.all_tags = params[:tags]
    newPost.save

  if newPost.save
    flash[:success] = 'Съобщението беше записано успешно. Благодарим!'
  else
    flash[:error] = "Съобщението съдържа грешки: #{newPost.errors.full_messages.to_sentence}"
  end
  user.posts<<newPost
  redirect '/'
end

post "/editPost/*" do 
  @id = params['splat'][0].to_i
  if params['pic']
    extension = params['pic'][:filename].split('.')[-1] 
    imageName = params['splat'][0].to_s[0..-2] + '.' + extension
    imagePath = 'public/' + imageName
    File.open(imagePath, "wb") do |f|
      f.write(params['pic'][:tempfile].read)
    end  
  else
    imageName = Post.find_by_id(@id).imagePath
  end
  Post.find_by_id(@id).all_tags = params[:tags]
  Post.find_by_id(@id).update(subject: params[:subject], theme:params[:theme], imagePath:imageName)
  redirect '/'
end

post "/addComment/*" do 
  comment = Comment.create content: params[:content] , published: DateTime.now
  currentPost = Post.find_by_id(params['splat'][0].to_i)
  currentPost.comments<<comment 
  session[:loginUser].comments<<comment 
  currentPost.save
  redirect '/'
end

post "/editComment/*" do 
  @id = params['splat'][0].to_i
  comment = Comment.find_by_id(@id)
  comment.content = params[:content]
  comment.save
  redirect '/'
end