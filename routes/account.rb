get "/register" do
  erb :registerMode
end 

get "/login" do
  erb :login
end 

get "/logout" do
  session[:loginUser] = false
  redirect '/'
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


post "/login" do 
  @loginUser = User.find_by_username params[:username]
  if !@loginUser
    flash[:error] = "Не съществува такова потребителстко име!"
    redirect '/login'  
  elsif @loginUser.password == params[:password]
    flash[:success] = "Влязохте успешно"
    session[:loginUser] = @loginUser
    redirect '/'
  else
    flash[:error] = "Неправилна парола!"
    redirect '/login'
  end
end
