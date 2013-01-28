class Snapito
  include HTTParty
  base_uri 'api.snapito.com'

  def initialize(u)
    @apikey = u
  end

  def desktop(url, size)
    "http://api.snapito.com/desktop/#{@apikey}/#{size}?url=#{url}&freshness=600"
  end

  def mobile(url, size)
    self.class.get("/mobile/#{@apikey}/#{size}?url=#{url}&freshness=600")
  end

  def web(url, size)
    self.class.get("/web/#{@apikey}/#{size}?url=#{url}&freshness=600")
  end

end
