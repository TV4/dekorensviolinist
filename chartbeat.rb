class Chartbeat
  include HTTParty
  base_uri 'api.chartbeat.com'

  def initialize(u)
    @apikey = u
  end

  def top_pages(host)
    self.class.get("/live/toppages/v3/?apikey=#{@apikey}&host=#{host}")['pages']
  end
end