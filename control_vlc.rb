require 'net/telnet'
require 'yaml'

settings = YAML.load_file('settings.yaml')

local_path = File.expand_path File.dirname(__FILE__)
image_dir = File.join(local_path, 'output_images')
template_dir = File.join(local_path, 'image_templates')

localhost = Net::Telnet::new("Host" => settings['vlc']['host'],
                             "Port" => settings['vlc']['port'],
                             "Timeout" => 10,
                             "Prompt" => /[$%#>\:] \z/)
clip_length = 0
title = ''


def get_movie_path(local_path)
  movies = Dir.glob(File.join(local_path,'movie_backgrounds', "*.mp4"))
  movies.first
end

def get_image_list(local_path)
  images = Dir.glob(File.join(local_path,'output_images', "*.png"))
  image_list = images.join ",3000;"
  image_list + ",3000"
end


def get_time(localhost)
  get_time = '>'
  while get_time.include? '>'
    localhost.cmd("get_time") { |c| get_time=c }
    get_time = get_time.split("\n").first
  end
  get_time.to_i
end

localhost.cmd("admin")
localhost.cmd("clear")
localhost.cmd("add #{get_movie_path(local_path)}")
localhost.cmd("seek 0")
localhost.cmd("play")

while true
  localhost.cmd("get_length") {|c| clip_length=c.to_i}
  localhost.cmd("get_title") {|c| title=c}
  puts "Clip is #{clip_length} #{title}"
  sleep 0.5
  localhost.cmd("@logo logo-file #{get_image_list(local_path)}")
  while get_time(localhost) < clip_length-1
    print "."
    sleep 0.5
  end

  localhost.cmd("@logo logo-file #{template_dir}/#{settings['templates']['files']['plain']}")
  sleep 1
  while get_time(localhost) > 2
    sleep 0.1
  end
end
localhost.close
