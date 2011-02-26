require 'rubygems'
require 'sinatra'
require 'json'
require_relative 'redis_jpn'

get '/autocomplete' do
  JSON.dump(complete(params[:term],10))
end
