node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'goapp' || ( node[:deploy][application][:layers] && ( node[:deploy][application][:layers] & node[:opsworks][:instance][:layers] ).count == 0 )
    Chef::Log.debug("Skipping goapp::rollback for application #{application} as it is not set as a goapp app for #{application} - restricted to layers: #{node[:deploy][application][:layers] || '<any>'}")
    next
  end

  deploy node[:deploy][application][:deploy_to] do
    user node[:deploy][application][:user]
    action 'rollback'
    restart_command "sleep #{node[:deploy][application][:sleep_before_restart]} && #{node[:goapp][application][:restart_server_command]}"

    only_if do
      File.exists?(node[:deploy][application][:current_path])
    end
  end

  ruby_block "restart goapp application #{application}" do
    block do
      Chef::Log.info("restart goapp application via: #{node[:goapp][application][:restart_server_command]}")
      Chef::Log.info(`#{node[:goapp][application][:restart_server_command]}`)
      $? == 0
    end
  end

end
