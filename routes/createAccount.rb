get "/register" do
  erb :registerMode
end 

post "/createProfile" do 
  newUser = User.new username: params[:username], isAdmin: 0 
  newUser.password= params[:password]
 
  if newUser.save
    flash[:success] = 'Регистрирах те се успешно!'
  redirect '/'
  else
    flash[:error] = "#{newUser.errors.full_messages.to_sentence}"
  redirect '/register'
  end
end