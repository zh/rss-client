require 'spec/helper'

class RSSFeed
  include RSSClient

  def self.fetch(*args)
    self.new.fetch(*args)
  end

  def fetch(url)
    get_feed url, OpenStruct.new
  end
end

describe RSSClient do
  describe 'basics' do
    before do
      @feed = RSSFeed.new
    end

    it 'should have an object identity' do
      @feed.should_not == RSSFeed.new
    end

    it 'should have useful defaults' do
      @feed.rssc_error.should == nil
      @feed.rssc_raw.should == nil
    end
  end

  describe 'parsing' do
    it 'can read a normal feed' do
      RSSFeed.fetch('http://rubyforge.org/export/rss_sfnews.php').entries.size.should >= 5
    end

    it 'can read weird feeds' do
      RSSFeed.fetch('http://dotmovfest.blogspot.com/feeds/posts/default').entries.size.should >= 5
    end
  end
end
