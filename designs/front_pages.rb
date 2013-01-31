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
      frontpages.each do |frontpage|
        frontpage_image = @snapito.desktop(URI.encode(frontpage[:url]),'768x432')
        cache_time= 60
        puts frontpage_image
        page = Page.new(@settings['templates']['files']['blue'], @settings)
        page.add_image frontpage_image, cache_time
        page.save "output_images/front_pages#{counter}.png"
        pages.push "output_images/front_pages#{counter}.png"
        counter += 1
      end
      lista = List.new 'kanalgrafik-landet.mp4', pages
    end

    def self.page_cache_time url
      return 60;
    end

  end
end



