require 'lib/general'
require 'hpricot'
require 'open-uri'

class String
  # Transforms this string into an escaped POSIX shell argument.
  def shell_escape
    inspect.gsub(/\\(\d{3})/) {$1.to_i(8).chr}
  end
end

def recursive_mkdir dirs
  base= ''
  dirs.split('/').each do |dir|
    base+= dir+'/'
    begin 
      FileUtils.mkdir base
    rescue
      puts 'dir already exists: '+base
    end
  end
  return base
end

def scrape_songs save_to, page_url
  doc= Hpricot open(page_url)
  doc.search("[@href*='mp3']|[@src*='mp3']").each do |song|
    url= song[:href]
    url= page_url+url unless url.match(/^http/)
    filename= File.basename url.sub(page_url, '')
    begin
      #puts "** DOWNLOADING #{url}"
      song= Song.create! :url=> url, :path=> save_to+filename
      %x[wget -c -O #{save_to+filename.shell_escape} #{url.shell_escape}]
      tags= ID3Lib::Tag.new(save_to+filename)
      unless tags.artist.nil?
        album_path= tags.album.nil? ? '' : tags.album+'/'
        dir= recursive_mkdir save_to+ tags.artist+'/'+ album_path
        
        FileUtils.mv save_to+filename, dir+filename
        song.path= dir+filename
        song.save!
      end
      puts 'waiting 3 seconds to download the next song.'
      sleep 3
      puts "and we're back!"
    rescue
      #puts "already downloaded #{url}"
    end
  end
end

while true do
  Site.find(:all).each do |site|
    scrape_songs './downloads/', site.url
  end
  Keyword.find(:all).each do |key|
    scrape_songs './scraps/', URI.encode('http://skreemr.com/results.jsp?q='+key.word)
  end
  puts "*****************************************"
  puts "* LOOKS LIKE ALL DA SONGS R DOWNLAODEDZ *"
  puts "*****************************************"
  puts "we'll be back in an hour to check for more songs"
  sleep 3600
  puts "we tirelessly toil but we never work."
end