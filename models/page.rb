# encoding: UTF-8
require 'RMagick'
include Magick
require 'httparty'
require 'yaml'
require "open-uri"
require 'digest/md5'
require 'uri'


class Page

  def initialize(original_image, settings)
    @img = ImageList.new(File.join(Page.local_path, 'image_templates', original_image)).first
    @settings = settings
  end

  def add_image(url, cache_timeout)
    overlay = Page.download_image(url, cache_timeout)
    overlay.background_color = "none"
    if @settings['image']['do_crop']
      overlay.crop!(0,@settings['image']['cut_top_pixels'],320,390)
    end
    if @settings['image']['resize']
      overlay.resize_to_fit!(@settings['image']['resize'])
    end
    overlay.rotate!(rand(18)-9)
    @img.composite!(overlay, @settings['image']['start_x'], @settings['image']['start_y'], Magick::OverCompositeOp)
  end

  def text(string, offset, bold)
    type_size = @settings['text']['type_size']
    color = '#' + @settings['text']['color']
    bold_font = @settings['text']['font_bold']
    plain_font = @settings['text']['font_plain']

    txt = Draw.new
    @img.annotate(txt, 0,0,200, offset, string){
      txt.gravity = Magick::NorthEastGravity
      txt.pointsize = type_size
      txt.fill = color
      if bold
        txt.font = File.join(Page.local_path, 'fonts', bold_font )
      else
        txt.font = File.join(Page.local_path, 'fonts', plain_font )
      end
      txt.text_antialias(true)
    }
  end

  def headline(string)
    text(string, 50, true)
  end

  def description(string)
    text(string, 75, false)
  end

  def save(file_name)
    @img.write(file_name)
  end

  def self.download_image(url, cache_timeout)
    image = Magick::ImageList.new
    file_name = File.join(Page.local_path, 'cached_images',Digest::MD5.hexdigest(url))
    if File.exist?(file_name) && File.new(file_name).mtime > Time.now-cache_timeout
      image.read(file_name)
    else
      begin
        puts "Downloading #{url}"
        urlimage = open(url)
        image.from_blob(urlimage.read)
        image.write(file_name)
      rescue Timeout::Error
        STDERR.print "Got timeout downloading #{url}"
      rescue OpenURI::HTTPError
        STDERR.print "Some error downloading #{url}"
      end


    end
    image
  end

  def self.local_path
    File.expand_path File.join(File.dirname(__FILE__),'..')
  end

end
