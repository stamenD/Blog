require 'spec_helper'

RSpec.describe 'Authorization', type: :feature do
  def create_and_login_regular_user username
    visit '/register'
    within 'form' do
      fill_in 'username', with: username
      fill_in 'password', with: '123qwe'
      fill_in 'mail', with: 'prime2@abv.bg'
    end
    click_button 'create'      
    visit '/login'
    within 'form[action="/login"]' do
      fill_in 'username', with: username
      fill_in 'password', with: '123qwe'
    end
    click_button 'login'
  end

  def create_and_login_admin
    visit '/register'
    within 'form' do
      fill_in 'username', with: 'admin'
      fill_in 'password', with: '123qwe'
      fill_in 'mail', with: 'prime@abv.bg'
    end
    click_button 'create'   
    page.driver.post "/makeAdmin/1"   
    visit '/login'
    within 'form[action="/login"]' do
      fill_in 'username', with: 'admin'
      fill_in 'password', with: '123qwe'
    end
    click_button 'login'
  end

  def create_post subject, theme, tags
    visit '/createPost'
    within 'form[action="/upload"]' do
      fill_in 'subject', with: subject
      fill_in 'theme', with: theme
      fill_in 'tags', with: tags
    end
    click_button 'post'
  end

  def logout_user
    visit '/'
    click_button 'logout'
  end

  def add_comment text, from, to
    visit '/login'
    within 'form[action="/login"]' do
      fill_in 'username', with: from
      fill_in 'password', with: '123qwe'
    end
    click_button 'login'
    page.driver.post("/addComment/#{to}")
    work = Comment.first
    work.content = text
    work.save
  end
  
  describe 'role: anonymous user' do
    context "login/register/forgot" do
      it 'allows accessing the login page and uses it' do
        visit '/login'
        expect(page.status_code).to eq(200)
        create_and_login_regular_user "martin"
        expect(page.get_rack_session_key('loginUser')).to eq User.first
      end
  
      it 'allows accessing the register page and uses it' do
        visit '/register'
        expect(page.status_code).to eq(200)
        create_and_login_regular_user "martin"
        logout_user
        expect(User.first.username).to eq("martin")
      end
  
      it 'allows accessing the forgot password page' do
        visit '/forgotPassword'
        expect(page.status_code).to eq(200)   
        visit '/newPassword'
        expect(page.status_code).to eq(200)
      end
  
      it 'does not allow accessing users page' do
        visit '/allUsers'
        expect(page.status_code).to eq(401)
      end
    end 
    context 'post' do
      it 'can read post' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        visit "/posts/1"
        expect(page).to have_content "something"
        expect(page).to have_content "first"
        expect(page.status_code).to eq(200)
      end
 
      it 'does not allow accessing create post page' do
        visit '/createPost'
        expect(page.status_code).to eq(401)
      end
     
      it 'does not permit editting a post' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        visit '/editPost/1'
        expect(page.status_code).to eq(401)
      end
     
      it 'does not permit deleting a post' do
        visit '/createPost'
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        visit '/'
        expect(page).not_to have_content "delete"
      end
    end
    context 'comment' do
      it 'can read a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user
        visit "/posts/1"
        expect(page).to have_content "my text is a very simple"
        expect(page.status_code).to eq(200)
      end
 
      it 'does not permit adding a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        visit "/posts/1"
        expect(page).not_to have_content "add comment"
      end
     
      it 'does not permit editting a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user
        visit '/editComment/1'
        expect(page.status_code).to eq(401)
      end
     
      it 'does not permit deleting a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user
          visit '/post/1'
          expect(page).not_to have_content "delete"
      end
    end
    context 'main page' do 
      it 'allows accessing the home page' do
        visit '/'
        expect(page.status_code).to eq(200)
      end
      it 'can view only posts with a certain tag' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        create_post "fourth" , "something" , ""
        logout_user
        visit '/'
        expect(page).to have_content("all")
        expect(page).to have_content("music")
        expect(page).to have_content("football")
        expect(page).to have_content("art")
        click_button ("music")
        expect(page).to have_content("first")
        expect(page).to have_content("second")
        expect(page).not_to have_content("third")
        expect(page).not_to have_content("fourth")
      end
      it 'can sort posts by date of publication (desc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        visit '/'
        click_button ("published")
        click_button ("published")
        expect(page.body.index("first")).to  be< page.body.index("second")
        expect(page.body.index("first")).to  be< page.body.index("third")
        expect(page.body.index("second")).to  be< page.body.index("third")
      end
      it 'can sort posts by date of publication (asc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        visit '/'
        click_button ("published")
        click_button ("published")
        click_button ("published")
        expect(page.body.index("first")).to  be> page.body.index("second")
        expect(page.body.index("first")).to  be> page.body.index("third")
        expect(page.body.index("second")).to  be> page.body.index("third")
      end
      it 'can sort posts by amount of comments (desc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.third.id
        logout_user      
        visit '/'
        click_button ("amount of comments")
        click_button ("amount of comments")
        expect(page.body.index("first")).to  be> page.body.index("third")
        expect(page.body.index("first")).to  be> page.body.index("second")
        expect(page.body.index("third")).to  be> page.body.index("second")
      end
      it 'can sort posts by amount of comments (asc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.third.id
        logout_user      
        visit '/'
        click_button ("amount of comments")
        click_button ("amount of comments")
        click_button ("amount of comments")
        expect(page.body.index("first")).to  be< page.body.index("third")
        expect(page.body.index("first")).to  be< page.body.index("second")
        expect(page.body.index("third")).to  be< page.body.index("second")
      end
    end
  end

  describe 'role: regular user' do
    context "login/register/forgot" do
      it 'does not allow accessing login page' do
        create_and_login_regular_user "martin"
        visit '/login'
        expect(page.status_code).to eq(401)
      end
  
      it 'does not allow accessing register page' do
        create_and_login_regular_user "martin"
        visit '/register'
        expect(page.status_code).to eq(401)
      end
      
      it 'does not allow accessing forgot password page' do
        create_and_login_regular_user "martin"
        visit '/forgotPassword'
        expect(page.status_code).to eq(401)   
        visit '/newPassword'
        expect(page.status_code).to eq(401)
      end
      it 'allow accessing users page' do
        create_and_login_regular_user "martin"
        visit '/allUsers'
        expect(page.status_code).to eq(200)
      end
    end
    context 'post' do
      it 'can read post' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        visit "/posts/1"
        expect(page).to have_content "something"
        expect(page).to have_content "first"
        expect(page.status_code).to eq(200)
      end
 
      it 'does not allow accessing create post page' do
        create_and_login_regular_user "martin"
        visit '/createPost'
        expect(page.status_code).to eq(401)
      end
     
      it 'does not permit editting a post' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        visit '/editPost/1'
        expect(page.status_code).to eq(401)
      end
     
      it 'does not permit deleting a post' do
        visit '/createPost'
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        visit '/'
        expect(page).not_to have_content("delete")
      end
    end
    context 'comment' do
      it 'can read a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user
        create_and_login_regular_user "martin"
        visit "/posts/1"
        expect(page).to have_content "my text is a very simple"
        expect(page.status_code).to eq(200)
      end
      it 'adds a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", 1
        visit "/posts/1"
        expect(page).to have_content "my comment"
        expect(page).to have_content "martin"
        expect(Post.first.comments.size).to eq(1)
        expect(Post.first.comments[0].user.username).to eq("martin")
        expect(page.status_code).to eq(200)
      end
      it 'can edit a own comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", 1
        visit '/editComment/1'
        within 'form' do
          fill_in 'comment', with: 'new content'
        end
        click_button 're-post' 
        visit "/posts/1"
        expect(page).to have_content 'new content'
        expect(page).to have_content "martin"
        expect(Post.first.comments.size).to eq(1)
        expect(Post.first.comments[0].user.username).to eq("martin")
        expect(page.status_code).to eq(200)
      end
      it 'can not edit a foreign comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", 1
        logout_user
        create_and_login_regular_user "ivan"
        visit '/editComment/1'
        expect(page.status_code).to eq(401)
      end
      it 'can delete a own comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", 1
        visit "/posts/1"
        expect(page).to have_content "delete"
        click_button 'delete' 
        # page.driver.post "/deleteComment/1"    
        visit "/posts/1"
        expect(page).not_to have_content "my comment"
        expect(Post.first.comments.size).to eq(0)
      end
      it 'can not delete a foreign comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", 1
        logout_user
        create_and_login_regular_user "ivan"
        visit '/post/1'
        expect(page).not_to have_content "delete"
      end
    end
    context 'main page' do 
      it 'allows accessing main page' do
        create_and_login_regular_user "martin"
        visit '/'
        expect(page.status_code).to eq(200)
      end
      it 'can view only posts with a certain tag' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        create_post "fourth" , "something" , ""
        logout_user
        create_and_login_regular_user "martin"
        visit '/'
        expect(page).to have_content("all")
        expect(page).to have_content("music")
        expect(page).to have_content("football")
        expect(page).to have_content("art")
        click_button ("music")
        expect(page).to have_content("first")
        expect(page).to have_content("second")
        expect(page).not_to have_content("third")
        expect(page).not_to have_content("fourth")
      end
      it 'can sort posts by date of publication (desc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        create_and_login_regular_user "martin"
        visit '/'
        click_button ("published")
        click_button ("published")
        expect(page.body.index("first")).to  be< page.body.index("second")
        expect(page.body.index("first")).to  be< page.body.index("third")
        expect(page.body.index("second")).to  be< page.body.index("third")
      end
      it 'can sort posts by date of publication (asc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        create_and_login_regular_user "martin"
        visit '/'
        click_button ("published")
        click_button ("published")
        click_button ("published")
        expect(page.body.index("first")).to  be> page.body.index("second")
        expect(page.body.index("first")).to  be> page.body.index("third")
        expect(page.body.index("second")).to  be> page.body.index("third")
      end
      it 'can sort posts by amount of comments (desc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.third.id
        logout_user      
        create_and_login_regular_user "martin"
        visit '/'
        click_button ("amount of comments")
        click_button ("amount of comments")
        expect(page.body.index("first")).to  be> page.body.index("third")
        expect(page.body.index("first")).to  be> page.body.index("second")
        expect(page.body.index("third")).to  be> page.body.index("second")
      end
      it 'can sort posts by amount of comments (asc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.third.id
        logout_user      
        create_and_login_regular_user "martin"
        visit '/'
        click_button ("amount of comments")
        click_button ("amount of comments")
        click_button ("amount of comments")
        expect(page.body.index("first")).to  be< page.body.index("third")
        expect(page.body.index("first")).to  be< page.body.index("second")
        expect(page.body.index("third")).to  be< page.body.index("second")
      end
    end    
  end

  describe 'role: admin' do
    context "login/register/forgot" do
      it 'does not allow accessing login page' do
        create_and_login_admin
        visit '/login'
        expect(page.status_code).to eq(401)
      end
  
      it 'does not allow accessing register page' do
        create_and_login_admin
        visit '/register'
        expect(page.status_code).to eq(401)
      end
      
      it 'does not allow accessing forgot password page' do
        create_and_login_admin
        visit '/forgotPassword'
        expect(page.status_code).to eq(401)   
        visit '/newPassword'
        expect(page.status_code).to eq(401)
      end
      it 'allow accessing users page and ability to make another user admin' do
        create_and_login_admin
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        visit '/login'
        within 'form[action="/login"]' do
          fill_in 'username', with: "admin"
          fill_in 'password', with: '123qwe'
        end
        click_button 'login'
        expect(User.second.isAdmin).to eq(0)
        visit '/allUsers'
        expect(page.status_code).to eq(200)
        expect(page).to have_content "Make admin"
        page.driver.post "/makeAdmin/2"  
        expect(User.second.isAdmin).to eq(1)
      end
    end
    context 'post' do
      it 'can read post' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        visit "/posts/1"
        expect(page).to have_content "something"
        expect(page).to have_content "first"
        expect(page.status_code).to eq(200)
      end
 
      it 'allows create post' do
        create_and_login_admin
        visit '/createPost'
        within 'form[action="/upload"]' do
          fill_in 'subject', with: "first post"
          fill_in 'theme', with: "common"
          fill_in 'tags', with: "music,art"
        end
        click_button 'post'        
        expect(Post.all.size).to eq(1)
        expect(Post.first.user_id).to eq(User.first.id)
        expect(User.first.posts[0]).to eq(Post.first)
      end
     
      it 'can edit a post' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        visit '/editPost/1'
        expect(page.status_code).to eq(200)
        within 'form' do
          fill_in 'subject', with: "new subject"
          fill_in 'theme', with: "new theme"
          fill_in 'tags', with: "art"
        end
        click_button 're-post'    
        visit '/'
        expect(Post.first.theme).to eq("new theme")    
        expect(Post.first.subject).to eq("new subject")    
        expect(Tag.all.size).to eq(1)     
      end
     
      it 'can delete a post' do
        create_and_login_admin
        visit '/'
        create_post "first" , "something" , "misic,football"
        visit '/'
        expect(page).to have_content "delete"
        click_button 'delete'
        expect(Post.all.size).to eq(0)
      end
    end
    context 'comment' do
      it 'can read a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        visit "/posts/1"
        expect(page).to have_content "my text is a very simple"
        expect(page.status_code).to eq(200)
      end
      it 'adds a comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my comment", "admin", Post.first.id
        visit "/posts/1"
        expect(page).to have_content "my comment"
        expect(page).to have_content "admin"
        expect(Post.first.comments.size).to eq(1)
        expect(Post.first.comments[0].user.username).to eq("admin")
        expect(page.status_code).to eq(200)
      end
      it 'can edit a own comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my comment", "admin", 1
        visit '/editComment/1'
        within 'form' do
          fill_in 'comment', with: 'new content'
        end
        click_button 're-post' 
        visit "/posts/1"
        expect(page).to have_content 'new content'
        expect(page).to have_content "admin"
        expect(Post.first.comments.size).to eq(1)
        expect(Post.first.comments[0].user.username).to eq("admin")
        expect(page.status_code).to eq(200)
      end
      it 'can edit a foreign comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", 1
        logout_user
        visit '/login'
        within 'form[action="/login"]' do
          fill_in 'username', with: "admin"
          fill_in 'password', with: '123qwe'
        end
        click_button 'login'
        visit '/editComment/1'
        within 'form' do
          fill_in 'comment', with: 'new content'
        end
        click_button 're-post' 
        visit "/posts/1"
        expect(page).to have_content 'new content'
        expect(page).to have_content "martin"
        expect(Post.first.comments.size).to eq(1)
        expect(Post.first.comments[0].user.username).to eq("martin")
        expect(page.status_code).to eq(200)
      end
      it 'can delete a own comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        add_comment "my comment", "admin", 1
        visit "/posts/1"
        expect(page).to have_content "delete"
        expect(Post.first.comments.size).to eq(1)
        click_button 'delete' 
        visit "/posts/1"
        expect(page).not_to have_content "my comment"
        expect(Post.first.comments.size).to eq(0)
      end
      it 'can delete a foreign comment' do
        create_and_login_admin
        create_post "first" , "something" , "misic,football"
        logout_user
        create_and_login_regular_user "martin"
        logout_user
        add_comment "my comment", "martin", Post.first.id
        logout_user
        visit '/login'
        within 'form[action="/login"]' do
          fill_in 'username', with: "admin"
          fill_in 'password', with: '123qwe'
        end
        click_button 'login'
        visit '/posts/1'
        expect(page).to have_content "delete"
        expect(Post.first.comments.size).to eq(1)
        click_button 'delete' 
        visit "/posts/1"
        expect(page).not_to have_content "my comment"
        expect(Post.first.comments.size).to eq(0)
      end
    end
    context 'main page' do 
      it 'allows accessing main page' do
        create_and_login_admin
        visit '/'
        expect(page.status_code).to eq(200)
      end
      it 'can view only posts with a certain tag' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        create_post "fourth" , "something" , ""
        visit '/'
        expect(page).to have_content("all")
        expect(page).to have_content("music")
        expect(page).to have_content("football")
        expect(page).to have_content("art")
        click_button ("music")
        expect(page).to have_content("first")
        expect(page).to have_content("second")
        expect(page).not_to have_content("third")
        expect(page).not_to have_content("fourth")
      end
      it 'can sort posts by date of publication (desc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        visit '/'
        click_button ("published")
        click_button ("published")
        expect(page.body.index("first")).to  be< page.body.index("second")
        expect(page.body.index("first")).to  be< page.body.index("third")
        expect(page.body.index("second")).to  be< page.body.index("third")
      end
      it 'can sort posts by date of publication (asc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        visit '/'
        click_button ("published")
        click_button ("published")
        click_button ("published")
        expect(page.body.index("first")).to  be> page.body.index("second")
        expect(page.body.index("first")).to  be> page.body.index("third")
        expect(page.body.index("second")).to  be> page.body.index("third")
      end
      it 'can sort posts by amount of comments (desc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.third.id
        visit '/'
        click_button ("amount of comments")
        click_button ("amount of comments")
        expect(page.body.index("first")).to  be> page.body.index("third")
        expect(page.body.index("first")).to  be> page.body.index("second")
        expect(page.body.index("third")).to  be> page.body.index("second")
      end
      it 'can sort posts by amount of comments (asc)' do
        create_and_login_admin
        create_post "first" , "something" , "music"
        create_post "second" , "something" , "music,football"
        create_post "third" , "something" , "art"
        logout_user
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.first.id
        logout_user      
        add_comment "my text is a very simple", "admin", Post.third.id
        visit '/'
        click_button ("amount of comments")
        click_button ("amount of comments")
        click_button ("amount of comments")
        expect(page.body.index("first")).to  be< page.body.index("third")
        expect(page.body.index("first")).to  be< page.body.index("second")
        expect(page.body.index("third")).to  be< page.body.index("second")
      end
    end        
  end
end
