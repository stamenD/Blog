require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end


FactoryGirl.define do

  factory :admin, class: User do
    username 'Mike123'
    mail 'mike@abv.bg'
    isAdmin 1
    after(:build) { |obj| obj.password="123qwe"  }
    after(:create) { |obj| obj.password="123qwe"  }
  end
 
  factory :user do
    username 'John123'
    mail 'john@abv.bg'
    isAdmin 0
    after(:build) { |obj| obj.password="123qwe"  }
    after(:create) { |obj| obj.password="123qwe"  }
  end
  

  sequence :string do |n|
     "person#{n}"
  end

  factory :comment do
    published DateTime.now 
    content { generate(:string) }
  end

  factory :post do
    subject { generate(:string) }
    theme "qweavadbsdfh dah adfh dfh adh"
    isActive 1
    published DateTime.now 
  end

  factory :unactivePost, class: Post do
    subject "football"
    theme "qweavadbsdfh dah adfh dfh adh"
    isActive 0
    published DateTime.now 
  end
end
