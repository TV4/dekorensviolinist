# encoding: UTF-8
require 'RMagick'
include Magick
require 'httparty'
require 'yaml'

require_relative 'chartbeat'
require_relative 'api4'

settings = YAML.load_file('settings.yaml')

chartbeat = Chartbeat.new(settings['chartbeat']['api_key'])
api_4 = API4.new()

local_path = File.expand_path File.dirname(__FILE__)

top_programs = []
chartbeat.top_pages('tv4play.se').each do |page|
  program = {}
  if page['path'].match /video_id=(\d+)/
    program['vman_id'] = $1
    program['title'] = page['title'].gsub(' - TV4 Play','')
    program['image'] = api_4.get_image_url(program['vman_id'])
    program['visitors'] = page['stats']['people']
    top_programs.push program
  elsif page['path'].match /se-tv-direkt\/([a-z0-9]*)/
    program['vman_id'] = live_to_vman_translation[$1]
    program['title'] = "Livekanal #{$1.upcase}"
    program['image'] = api_4.get_image_url(program['vman_id'])
    program['visitors'] = page['stats']['people']
    top_programs.push program
  end
end

original_image = ImageList.new(File.join(local_path, 'image_templates', settings['templates']['files']['blue']))
counter = 0
top_programs.each do |program|
  img = original_image.copy
  overlay = Magick::Image.read(program['image']).first
  overlay.background_color = "none"
  overlay.resize_to_fit!(250)
  overlay.rotate!(rand(18)-9)
  img.composite!(overlay, 50, 50, Magick::OverCompositeOp)

  txt = Draw.new
  img.annotate(txt, 0,0,200,0, "#{counter+1}.  #{program['title'].upcase.tr('åäö','ÅÄÖ')}"){
    txt.gravity = Magick::EastGravity
    txt.pointsize = settings['text']['type_size']
    txt.fill = '#' + settings['text']['color']
    txt.font = File.join(local_path, 'fonts',settings['text']['font_bold'])
    txt.text_antialias(true)
  }
  img.annotate(txt, 0,0,200,25, "#{program['visitors']} besökare"){
    txt.gravity = Magick::EastGravity
    txt.pointsize = settings['text']['type_size']
    txt.fill = '#' + settings['text']['color']
    txt.font = File.join(local_path, 'fonts',settings['text']['font_plain'])
    txt.text_antialias(true)
  }

  img.write("output_images/mostviewed#{counter}.png")
  counter += 1
end




