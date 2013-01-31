require 'net/telnet'
require 'yaml'

require_relative 'models/list'

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

background_to_foreground = {'kanalgrafik-snotrad.mp4' => 'site_pages', 'kanalgrafik-fotbollsplan.mp4' => 'play_programs', 'kanalgrafik-landet.mp4' => 'front_pages'}

lista = List.new nil, nil

def get_value(command,localhost)
  tries = 10
  get_time = '>'
  while get_time.include? '>' and tries > 0
    get_time = ''
    localhost.cmd("get_#{command}") { |c| get_time+=c }
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
localhost.cmd("add #{lista.get_movie_path(local_path, settings, background_to_foreground.keys[0])}")
localhost.cmd("add #{lista.get_movie_path(local_path, settings, background_to_foreground.keys[2])}")
localhost.cmd("add #{lista.get_movie_path(local_path, settings, background_to_foreground.keys[1])}")
localhost.cmd("add #{lista.get_movie_path(local_path, settings, background_to_foreground.keys[2])}")
localhost.cmd("@logo logo-opacity 255")
localhost.cmd("seek 0")
localhost.cmd("loop on")
localhost.cmd("play")


iteration = 0
while true
  clip_length = get_length(localhost)
  title = get_title(localhost)
  puts "Clip is #{clip_length} #{title}"
  sleep 0.5
  puts  background_to_foreground[title]
  localhost.cmd("@logo logo-file #{lista.get_image_list(local_path, background_to_foreground[title])}")
  while get_time(localhost) < clip_length-1
    print "."
    sleep 0.5
  end

  localhost.cmd("@logo logo-file #{template_dir}/#{settings['templates']['files']['plain']}")
  sleep 1
  while get_time(localhost) > 2
    sleep 0.1
  end
  iteration += 1
end
localhost.close
