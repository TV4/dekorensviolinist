# encoding: UTF-8
require 'RMagick'
include Magick
require 'httparty'
require 'yaml'
require "open-uri"
require 'digest/md5'

require_relative 'chartbeat'
require_relative 'api4'

def download_image(url)
  image = Magick::ImageList.new
  digest =
      file_name = File.join('cached_images',Digest::MD5.hexdigest(url))
  if File.exist?(file_name)
    image.read(file_name)
  else
    urlimage = open(url)
    image.from_blob(urlimage.read)
    image.write(file_name)
  end
  image
end

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
    program['vman_id'] = api_4.vman_from_live_feed($1)
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
  overlay = download_image(program['image']).first
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




