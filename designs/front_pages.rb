# encoding: UTF-8
require_relative '../models/page'
require_relative '../models/list'

require_relative '../services/chartbeat'
require_relative '../services/api4'
require_relative '../services/snapito'

module DekorDesign

  class FrontPages

    def initialize(settings)
      @settings = settings
      @snapito = Snapito.new(@settings['snapito']['api_key'])
    end

    def update_interval
      30
    end

    def create_images
      frontpages = [{url: 'http://www.tv4.se/'}, {url: 'http://www.recept.nu/'}, {url: 'http://www.tv4play.se/'}, {url: 'http://www.fotbollskanalen.se/'}]

      counter = 0

      pages = []
      p frontpages
      frontpages.each do |frontpage|
        frontpage_image = @snapito.desktop(URI.encode(frontpage[:url]),'320x600')
        cache_time= 60
        puts frontpage_image
        page = Page.new(@settings['templates']['files']['blue'], @settings)
        page.add_image frontpage_image, cache_time
        page.save "output_images/front_pages#{counter}.png"
        pages.push "output_images/front_pages#{counter}.png"
        counter += 1
      end
      lista = List.new 'kanalgrafik-snotrad.mp4', pages
    end

    def self.page_cache_time url
      if url == 'tv4.se/'
        return 5*60
      elsif url.match /tv4.se\/(nyheterna|sport)(\/)?$/
        return 10*60
      elsif url.match /tv4.se\/[^\/]+(\/)?$/
        return 30*60
      elsif url.match /tv4.se\/[^\/]+\/(artiklar|avsnitt|klipp)\/?$/
        return 60*60
      else
        return 86400*365
      end
    end

  end
end



