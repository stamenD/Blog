get "/register" do
  @language = findLanguage
  erb :registerMode
end 

get "/login" do
  @language = findLanguage
  erb :login
end 

get "/allUsers" do
  @language = findLanguage
  erb :allUsers
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

post "/logout" do
  session[:loginUser] = false
  redirect '/'
end 

post "/makeAdmin/*" do
  a = User.find_by_id(params['splat'][0].to_i)
  a.isAdmin=1
  a.save
  redirect '/'
end