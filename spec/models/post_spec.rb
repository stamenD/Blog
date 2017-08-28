require 'spec_helper'

RSpec.describe Post do

  describe '#changeStutus' do  
    it 'changes post status from unactive to active' do
      post = create(:unactivePost)
      post.changeStutus
      expect(post.isActive).to eq 1
    end
    
    it 'changes post status from active to unactive' do
      post = create(:post)
      post.changeStutus
      expect(post.isActive).to eq 0
    end  
  end

  describe '#changeStutus' do 
    it 'returns number of comments when post has the ones' do
      post = create(:post)
      comment1 = create(:comment)
      comment2 = create(:comment)
      comment3 = create(:comment)
      post.comments<<comment1<<comment2<<comment3
      expect(post.comments_number).to eq 3
    end
    
    it 'returns zero when post has not any commnets' do
      post = create(:post)
      expect(post.comments_number).to eq 0
    end
  end

  describe '#all_tags=' do 
    it 'makes some tags to belong to post' do
      post = create(:post)
      post.all_tags= "football,music"
      expect(post.tags.size).to eq 2
    end

    it 'does not makes any tags to belong to post when give empty string' do
      post = create(:post)
      post.all_tags= ""
      expect(post.tags.size).to eq 0
    end

    it 'does not makes any tags to belong to post when give invalid string' do
      post = create(:post)
      post.all_tags= ",   ,"
      expect(post.tags.size).to eq 0
    end
  end
  
  describe '#all_tags' do 
    it 'returns all tags which belong to post' do
      post = create(:post)
      post.all_tags= "football,music"
      expect(post.all_tags).to eq "football,music"
    end

    it 'returns empty string when post does not have any tags' do
      post = create(:post)
      expect(post.all_tags).to eq ""
    end
  end

  describe '.tagged_with' do 
    it 'returns all posts which have the precisely defined tag' do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)
      post4 = create(:post)
      post1.all_tags= "football,music"
      post3.all_tags= "football"
      expect(Post.tagged_with("football")[0]).to eq post1
      expect(Post.tagged_with("football")[1]).to eq post3
    end
 
    it "does not return any posts when the precisely defined tag does not meet in post's tags" do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)
      post4 = create(:post)
      post1.all_tags= "football,music"
      post3.all_tags= "football"
      expect(Post.tagged_with("art")).to eq []
    end
  end

  describe '#print' do     
    it 'uses currectly markdown syntax for bold' do
      post = build(:post)
      post.theme = "** some string **"
      expect(post.print).to eq "<b> some string </b>"       
    end
    
    it "uses currectly markdown syntax for italic" do
      post = build(:post)
      post.theme = "* some string *"
      expect(post.print).to eq "<i> some string </i>"       
    end

    it 'uses currectly markdown syntax for url' do
      post = build(:post)
      post.theme = "[link](https://www.google.com)"
      expect(post.print).to eq "<a href=\"https://https://www.google.com\">link</a>"       
   
    end

    it 'uses currectly markdown syntax for headers' do
      post = build(:post)
      post.theme = "# H1"
      expect(post.print).to eq "<h1> H1</h1>"        
      post.theme = "## H2"
      expect(post.print).to eq "<h2> H2</h2>"        
      post.theme = "### H3"
      expect(post.print).to eq "<h3> H3</h3>"        
      post.theme = "#### H4"
      expect(post.print).to eq "<h4> H4</h4>"        
      post.theme = "##### H5"
      expect(post.print).to eq "<h5> H5</h5>"        
      post.theme = "###### H6"
      expect(post.print).to eq "<h6> H6</h6>"        
    end         
  end
end
