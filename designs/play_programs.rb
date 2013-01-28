# encoding: UTF-8

require_relative '../services/chartbeat'
require_relative '../services/api4'
require_relative '../services/snapito'
require_relative '../models/page'
require_relative '../models/list'
require 'yaml'

module DekorDesign

  class PlayPrograms

    def initialize(settings)
      @settings = settings
      @chartbeat = Chartbeat.new(@settings['chartbeat']['api_key'])
      @api_4 = API4.new()
    end

    def update_interval
      30
    end

    def create_images_s
      top_programs = []
      @chartbeat.top_pages('tv4play.se').each do |page|
        program = {}
        if page['path'].match /video_id=(\d+)/
          program['vman_id'] = $1
          program['title'] = page['title'].gsub(' - TV4 Play','')
          program['image'] = @api_4.get_image_url(program['vman_id'])
          program['visitors'] = page['stats']['people']
          program['image_cache_time'] = SitePages.page_cache_time page['path']
          top_programs.push program
        elsif page['path'].match /se-tv-direkt\/([a-z0-9]*)/
          program['vman_id'] = @api_4.vman_from_live_feed($1)
          program['title'] = "Livekanal #{$1.upcase}"
          program['image'] = @api_4.get_image_url(program['vman_id'])
          program['visitors'] = page['stats']['people']
          program['image_cache_time'] = SitePages.page_cache_time page['path']
          top_programs.push program
        end
      end

      counter = 0
      pages = []
      top_programs.each do |program|
        page = Page.new(@settings['templates']['files']['blue'], @settings)
        page.add_image program['image'], program['image_cache_time']
        page.headline "#{counter+1}.  #{program['title'].upcase.tr('åäö','ÅÄÖ')}"
        page.description "#{program['visitors']} besökare"
        page.save "output_images/play_programs#{counter}.png"
        pages.push "output_images/play_programs#{counter}.png"
        counter += 1
      end
      lista = List.new 'kanalgrafik-snotrad.mp4', pages
    end

    def self.page_cache_time url
      6400*365
    end

  end
end


