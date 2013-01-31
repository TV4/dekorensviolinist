# encoding: UTF-8
require_relative '../models/page'
require_relative '../models/list'

require_relative '../services/chartbeat'
require_relative '../services/api4'
require_relative '../services/snapito'

module DekorDesign

  class SitePages

    def initialize(settings)
      @settings = settings
      @chartbeat = Chartbeat.new(@settings['chartbeat']['api_key'])
      @snapito = Snapito.new(@settings['snapito']['api_key'])
    end

    def update_interval
      30
    end

    def create_images
      top_programs = []
      @chartbeat.top_pages('tv4.se').each do |page|
        program = {}
        program['title'] = page['title'].gsub(' - tv4.se','')[0..35]
        program['image'] = @snapito.desktop(URI.encode('http://www.'+page['path']),'320x600')
        program['image_cache_time'] = SitePages.page_cache_time page['path']
        program['visitors'] = page['stats']['people']
        top_programs.push program
      end

      counter = 0

      pages = []
      top_programs.each do |program|
        page = Page.new(@settings['templates']['files']['blue'], @settings)
        page.add_image program['image'], program['image_cache_time']
        page.headline "#{counter+1}.  #{program['title'].upcase.tr('åäö','ÅÄÖ')}"
        page.description "#{program['visitors']} besökare"
        page.save "output_images/site_pages#{counter}.png"
        pages.push "output_images/site_pages#{counter}.png"
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



