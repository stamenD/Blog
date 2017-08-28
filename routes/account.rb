get "/register" do
  @language = findLanguage
  if !session[:loginUser]
     erb :registerMode
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end
end 

get "/login" do
  @language = findLanguage
  if !session[:loginUser]
     erb :login
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end 
end 

get "/forgotPassword" do
  @language = findLanguage
  if !session[:loginUser]
    erb :forgotPassword
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end 
end 

get "/allUsers" do
  @language = findLanguage
  if session[:loginUser]
    erb :allUsers
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end 
end 

get "/newPassword" do
  @language = findLanguage
  if !session[:loginUser]
    if User.find_by_token(params[:token])
      @receiveID = User.find_by_token(params[:token]).id
      erb :newPassword 
    else
      flash[:error] = "Невалиден token"
      redirect '/'
    end 
  else
    flash[:error] = "Нямаш достъп до тази страница"
    session[:status] = 401
    redirect '/'
  end 
end


post "/createProfile" do 
  newUser = User.new username: params[:username],mail: params[:mail], isAdmin: 0 
  newUser.password= params[:password]
  newUser.token = SecureRandom.urlsafe_base64

  if newUser.save
    flash[:success] = 'Регистрирахте се успешно!'
    status 200
    redirect '/'
  else
    # flash[:error] = "#{newUser.errors.full_messages.to_sentence}"
    halt 403, "#{newUser.errors.full_messages.to_sentence}"
  end
end

post "/login" do 
  @loginUser = User.find_by_username params[:username]
  if !@loginUser
    flash[:error] = "Не съществува такова потребителстко име!"
    # status 401
    redirect '/login'  
  elsif @loginUser.password == params[:password]
    flash[:success] = "Влязохте успешно"
    status 200
    session[:loginUser] = @loginUser
    redirect '/'
  else
    flash[:error] = "Неправилна парола!"
    # status 401
    redirect '/login'
  end
end

post "/logout" do
  session[:loginUser] = false
  redirect '/'
end 

post "/forgotPassword" do
  if User.find_by_mail(params[:email])
    user = User.find_by_mail(params[:email])
    user.token = SecureRandom.urlsafe_base64
    link = "http://localhost:4567/newPassword?token=#{user.token}"
    Pony.options = {
      :subject => "Нова парола",
      :body => "#{link}",
      :via => :smtp,
      :via_options => {
      :address              => 'smtp.gmail.com',
      :port                 => '587',
      :enable_starttls_auto => true,
      :user_name            => "stamendragoew@gmail.com",
      :password             => "",
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "localhost.localdomain"
      }
    }
    user.save
    Pony.mail(:to => params[:email])
    redirect '/'
  else
    flash[:error] = "Не съществува потрибител с този e-mail"
    redirect '/forgotPassword'
  end
end

post '/newPassword/:id' do
  if params[:password] != params[:password2]
    flash[:error] = "Неправилна парола!"
    redirect '/'
  else
    user = User.find_by_id(params[:id])
    user.password = params[:password]
    user.save!
    flash[:error] = "Успешно промени паролата си!"
    redirect '/'
  end
end

post "/makeAdmin/*" do
  a = User.find_by_id(params['splat'][0].to_i)
  a.isAdmin = 1
  a.save
  redirect '/'
end