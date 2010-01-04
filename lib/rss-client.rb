require 'timeout'
require 'ostruct'
require 'rss-client/http-access2'
require 'feed-normalizer'
require 'digest/sha1'

module RSSClient

  attr_reader :rssc_error    # save the last error message
  attr_reader :rssc_raw      # the raw RSS saved for additional processing

protected

  def guid_for(rss_entry)
    guid = rss_entry.urls.first
    guid = rss_entry.id.to_s if rss_entry.id
    return Digest::SHA1.hexdigest("--#{guid}--myBIGsecret")
  end

  def fix_content(content, site_link)
    content = CGI.unescapeHTML(content) unless /</ =~ content
    correct_urls(content, site_link)
  end
  
  def correct_urls(text, site_link)
    site_link += '/' unless site_link[-1..-1] == '/'
    text.gsub(%r{(src|href)=(['"])(?!http)([^'"]*?)}) do
      first_part = "#{$1}=#{$2}"
      url = $3
      url = url[1..-1] if url[0..0] == '/'
      "#{first_part}#{site_link}#{url}"
    end
  end

  # opts is an OpenStruct
  # set last_fetch_time to nill to force fresh fetch
  def get_feed(url, opts)

    opts.extra = Hash.new
    opts.extra["Connection"] = "close"
    # some sites need User-Agent field
    opts.extra["User-Agent"] = "RSSClient/2.0.9"

    # Ask for changes (get 304 code in response)
    # opts.since is Time::
    if not opts.forceUpdate and opts.since
      time = Time.parse(opts.since.to_s)
      opts.extra["If-Modified-Since"] = time.httpdate() if time
    end

    begin
      @rssc_raw = get_url(url, opts)
      return nil unless @rssc_raw

      case @rssc_raw.status
      when 200 # good
      when 301, 302 # follow redirect ...
        @rssc_raw = get_url(@rssc_raw.header["Location"], opts)
        return nil unless @rssc_raw

      when 304 # Not modified - nothing to do
        return nil

      # errors
      when 401
        raise RuntimeError, "access denied, " + @rssc_raw.header['WWW-Authenticate'].to_s
      when 404
        raise RuntimeError, "feed [ #{url} ] not found"
      else
        raise RuntimeError, "can't fetch feed (unknown response code: #{@rssc_raw.status})"
      end

      return nil unless @rssc_raw.content

      # Parse the raw RSS
      begin
        FeedNormalizer::FeedNormalizer.parse(@rssc_raw.content, :try_others => true)
      rescue NoMethodError
        # undefined method `channel' for #<RSS::Atom::Feed:0x9f03b70>
        # try a simpler parser ...
        FeedNormalizer::FeedNormalizer.parse(@rssc_raw.content,
          :try_others => true, :force_parser => FeedNormalizer::SimpleRssParser
        )
      end
    rescue RuntimeError => error
      @rssc_error = error
      return nil
    end  
  end

  # opts is an OpenStruct
  def get_url(url, opts)
    begin
      Timeout::timeout(opts.giveup) do
        client = HTTPAccess2::Client.new
	# FIXME: set additional client options here
	client.ssl_config.verify_mode = nil
	client.proxy = opts.proxy
	uri = URI.parse(url.to_s)
	client.set_basic_auth(url, uri.user, uri.password ) if uri.user and uri.password
        return client.get(url, nil, opts.extra)
      end
    rescue URI::InvalidURIError => error
      raise RuntimeError, "Invalid URL (#{error})"

    rescue TimeoutError => error
      raise RuntimeError, "Connection timeout (#{error})"

    rescue SocketError => error
      raise RuntimeError, "Socket error (#{error})"

    rescue
      raise RuntimeError, "can't fetch feed (#{$!})"
    else
      return nil
    end
  end

end
