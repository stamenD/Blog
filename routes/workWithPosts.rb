get "/createPost" do
  erb :createPost
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