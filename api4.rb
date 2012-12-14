class API4
  include HTTParty
  base_uri 'webapi.tv4play.se'

  def vman_from_live_feed(live_feed)
    live_to_vman_translation = {'tv4' => 2219145, 'sjuan' => 2219146, 'tv11' => 2219148, 'tv4-sport' => 2211912,
                                'tv4-sport-xtra' => 2187044, 'tv4-news' => 2143280, 'tv4-fakta' => 2219150,
                                'tv4-fakta-xl' => 2219153, 'tv4-film' => 2219156,
                                'tv4-komedi' => 2219154, 'tv4-guld' => 2219155}
    live_to_vman_translation[live_feed]
  end

  def get_image_url(vman_id)
    data = self.class.get("/video/programs/search.json?vmanid=#{vman_id}")
    data['results'][0]['originalimage']
  end
end
