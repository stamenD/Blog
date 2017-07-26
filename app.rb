require 'sinatra'
require 'sinatra/activerecord'
require "thin"
require "sinatra/flash"
require 'i18n'
require 'i18n/backend/fallbacks'
require "pony"
require 'bcrypt'

require_relative "routes/main"
require_relative "routes/account"
require_relative "routes/post"
require_relative "models/post"
require_relative "models/tag"
require_relative "models/tagging"
require_relative "models/user"
require_relative "models/comment"


configure do
  enable :sessions
  set :server, %w[thin]
  set :root, __dir__
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  I18n.load_path = Dir["#{__dir__}/config/locales/*.yml"]
  I18n.backend.load_translations
end
