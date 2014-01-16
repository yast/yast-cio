require "yast/rake"

Yast::Tasks.configuration do |conf|
  conf.skip_license_check << /lscss.output.*/
  
  conf.obs_api = "https://api.suse.de/"

  conf.obs_project = "Devel:YaST:Head"

  conf.obs_sr_project = "SUSE:Factory:Head:Internal"

  conf.obs_target = "factory"
end
