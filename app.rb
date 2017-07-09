require 'sinatra'
require 'sinatra/activerecord'
require "thin"
require "sinatra/flash"

require_relative "models/post"
require_relative "routes/main"
configure do
  enable :sessions
  set :root, __dir__
end