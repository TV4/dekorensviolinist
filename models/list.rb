# encoding: UTF-8
require 'RMagick'
include Magick
require 'httparty'
require 'yaml'
require "open-uri"
require 'digest/md5'
require 'uri'

class List

  def initialize(video_background, pages)
    @video_background = video_background
    @pages = pages
  end

  def get_movie_path(local_path, settings, prefix = '')
    if prefix != ''
      movies = Dir.glob(File.join(local_path,'movie_backgrounds', prefix))
      movies.first
    elsif settings['movie']['prefer']
      File.join(local_path,'movie_backgrounds', settings['movie']['prefer'])
    else
      movies = Dir.glob(File.join(local_path,'movie_backgrounds', "#{prefix}*.mp4"))
      movies.first
    end
  end

  def get_image_list(local_path, prefix)
    blank_image = File.join(local_path,'image_templates', "blank.png")
    images = Dir.glob(File.join(local_path,'output_images', prefix + "*.png")).sort
    image_list = images.join ",3000;"
    image_list + ",3000;#{blank_image},30000"
  end

end
