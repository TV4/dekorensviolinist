# encoding: UTF-8

require 'yaml'

def load_local_settings(name)
  settings_file = 'designs/' + name.gsub('::','-') + '.yaml'
  if File.exist?(settings_file)
    YAML.load_file(settings_file)
  else
    {}
  end
end

stats = {}

# load settings
settings = YAML.load_file('settings.yaml')

Dir.glob("designs/*.rb") do |modul|
  load modul
end

modules = []

ObjectSpace.each_object(Class) do |o|
  if not o.name.nil? and o.name.include? 'DekorDesign'
    design = Object.const_get("DekorDesign").const_get(o.name.gsub('DekorDesign::','')).new settings.merge load_local_settings o.name
    if design.class.method_defined? :create_images
      modules.push design
    end
  end
end

while true
  modules.each do |modul|
    if not stats.has_key? modul or Time.now - stats[modul]['last_run'] > modul.update_interval
      puts modul
      modul.create_images
      if stats.has_key? modul
        stats[modul]['last_run'] = Time.now
      else
        stats[modul] = {'last_run' => Time.now  }
      end
    end
  end
  sleep 1
end
