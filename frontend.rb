require 'lib/general'
require 'sinatra'
require 'haml'

require 'ruby-debug' ; debugger

get '/' do
  haml :home
end


# songs
get '/songs' do
  @songs= Song.find :all
  haml :songs
end

put '/songs/:id' do
  @song= Song.find params[:id]
  @song.tags.title= params[:title]
  @song.tags.update!
  @song.tags= nil
  @song.tags.title
end

#edit key words to scrape
get '/keywords' do
  @keywords= Keyword.find :all
  haml :keywords
end

post '/keywords' do
  Keyword.create! params unless params[:word].nil?
end

post '/websites' do
  Site.create! params unless params[:url].nil?
end

delete '/keywords/:word' do
  (Keyword.find_by_word params[:word]).destroy
end

get '/websites' do
  @websites= Site.find :all
  haml :websites
end