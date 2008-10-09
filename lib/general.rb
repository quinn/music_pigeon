require 'rubygems'
require 'active_record'
require 'sqlite3'
require 'id3lib'
require 'fileutils'

ActiveRecord::Base.establish_connection(:adapter=> 'sqlite3', :dbfile=> 'scrape_data.db')
class Song < ActiveRecord::Base
  def tags
    @tags||= ID3Lib::Tag.new path
  end
  
  def tags= val
    @tags= val
  end
  
  def title
    tags.title.split('').map{|c| c.unpack('Z')}.join unless tags.title.nil?
  end
  
  def artist
    tags.artist.split('').map{|c| c.unpack('Z')}.join unless tags.artist.nil?
  end
end
class Site < ActiveRecord::Base 
end
class Keyword < ActiveRecord::Base
end