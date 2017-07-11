get "/createPost" do
  erb :createPost
end 

get "/posts/:readPost" do
  @receiveID = params[:readPost]
  erb :readPost
end 

get "/changePostStatus/*" do 
  @id = params['splat'][0].to_i
  post = Post.find_by_id(@id)
  post.changeStutus
  post.save
  redirect '/'
end

get "/editPost/*" do
 @receiveID = params['splat'][0].to_i
  erb :editPost
end 

get "/deletePost/*" do
  @id2 = params['splat'][0].to_i
  Post.destroy(@id2)
  redirect '/'
end

post "/upload" do 
  user = session[:loginUser]
  newPost = Post.create subject: params[:subject], theme:params[:theme] , published: DateTime.now ,isActive: 1
  if params['pic']
    extension=params['pic'][:filename].split('.')[-1]
    imageName = newPost.id.to_s + '.' + extension
    imagePath = 'public/' + imageName    
    File.open(imagePath, "wb") do |f|
      f.write(params['pic'][:tempfile].read)
    end
  else
    imageName = "default.gif"
  end
    newPost.imagePath = imageName
    newPost.all_tags = params[:tags]
    newPost.save

  if newPost.save
    flash[:success] = 'Съобщението беше записано успешно. Благодарим!'
  else
    flash[:error] = "Съобщението съдържа грешки: #{newPost.errors.full_messages.to_sentence}"
  end
  redirect '/'
end

post "/*" do 
  @id = params['splat'][0].to_i
  if params['pic']
    extension=params['pic'][:filename].split('.')[-1] 
    imageName = params['splat'][0].to_s[0..-2] + '.' + extension
    imagePath = 'public/' + imageName
    File.open(imagePath, "wb") do |f|
      f.write(params['pic'][:tempfile].read)
    end  
  else
    imageName = Post.find_by_id(@id).imagePath
  end
  Post.find_by_id(@id).update(subject: params[:subject], theme:params[:theme], imagePath:imageName)
  redirect '/'
end