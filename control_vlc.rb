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
  blank_image = File.join(local_path,'image_templates', "blank.png")
  images = Dir.glob(File.join(local_path,'output_images', "*.png")).sort
  image_list = images.join ",3000;"
  image_list + ",3000;#{blank_image},30000"
end


def get_value(command,localhost)
  tries = 10
  get_time = '>'
  while get_time.include? '>' and tries > 0
    get_time = ''
    localhost.cmd("get_#{command}") { |c| get_time+=c }
    puts get_time
    get_time = get_time.split("\n").first
    tries = tries - 1
  end
  get_time
end

def get_time(localhost)
  get_value('time',localhost).to_i
end

def get_length(localhost)
  get_value('length',localhost).to_i
end

def get_title(localhost)
  get_value('title',localhost)
end

localhost.cmd("admin")
localhost.cmd("clear")
localhost.cmd("add #{get_movie_path(local_path)}")
localhost.cmd("@logo logo-opacity 255")
localhost.cmd("seek 0")
localhost.cmd("loop on")
localhost.cmd("play")

while true
  clip_length = get_length(localhost)
  title = get_title(localhost)
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
