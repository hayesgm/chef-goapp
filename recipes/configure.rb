include_recipe 'golang'

node[:deploy].each do |application, _|
  # If you have multiple go apps, each server is going to run them
  # This might not be desired for separation purposes, and thus we'll only run apps where
  # json matching that layer matches the application
  if node[:deploy][application][:application_type] != 'goapp' || ( node[:deploy][application][:layers] && ( node[:deploy][application][:layers] & node[:opsworks][:instance][:layers] ).count == 0 )
    Chef::Log.debug("Skipping goapp::configure for application #{application} as it is not set as a goapp app for #{application} - restricted to layers: #{node[:deploy][application][:layers] || '<any>'}")
    next
  end
  
  goapp_user_and_group do
    user    node[:deploy][application][:user]
    group   node[:deploy][application][:group]
    home    node[:deploy][application][:home]
    shell   node[:deploy][application][:shell]
  end
  
  goapp_deploy_dir do
    user    node[:deploy][application][:user]
    group   node[:deploy][application][:group]
    path    node[:deploy][application][:deploy_to]
  end
  
end
