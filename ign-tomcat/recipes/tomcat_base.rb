## encoding: UTF-8
#
# --
# Copyright (C) 20010-2012 IGN Entertainment.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

#
#
# Parameters:
#--
# TODO: 
# 
#++
# 


#-----
include_recipe "ign-tomcat::user"
include_recipe "ign-tomcat::tomcat_home"

tomcat_group = node[:tomcat][:group]
tomcat_user = node[:tomcat][:user]
## Tomcat Home 
tomcat_home   = node[:tomcat][:home]
tomcat_extras = node[:tomcat][:extras]

#-----------------------------------------------------------------------------------------------------------------------
#Setup CATALINA BASE

tomcat_base    = "#{node[:tomcat][:base]}"
tomcat_conf    = "#{node[:tomcat][:conf]}"
tomcat_logs    = "#{node[:tomcat][:logs]}"
tomcat_out     = "#{node[:tomcat][:out]}"
tomcat_temp    = "#{node[:tomcat][:temp]}"
tomcat_lib     = "#{node[:tomcat][:base]}/lib"
tomcat_webapps = "#{node[:tomcat][:webapps]}"

tomcat_service  = node[:tomcat][:service]
tomcat_script   = node[:tomcat][:script]
tomcat_launcher = node[:tomcat][:launcher]

script_vars = {
    :tomcat_home     => tomcat_home,
    :tomcat_base     => tomcat_base,
    :tomcat_temp     => tomcat_temp,
    :tomcat_lib      => tomcat_lib,
    :tomcat_logs     => tomcat_logs,
    :tomcat_out      => tomcat_out,
    :tomcat_group    => tomcat_group,
    :tomcat_user     => tomcat_user,
    :tomcat_conf     => tomcat_conf,
    :tomcat_launcher => tomcat_launcher

}

directory tomcat_base do
  action :create
  recursive true
  owner 'root'
  group tomcat_group
  mode "0700"
end

#CATALINA BASE User
user tomcat_user do
  comment "Apache Tomcat Base #{tomcat_user}"
  gid tomcat_group
  shell "/bin/sh"
  home tomcat_base
end

[tomcat_base, tomcat_conf, tomcat_logs, tomcat_temp, tomcat_lib, tomcat_webapps].each do |dir|
  log "Resource:\t#{dir}"
  directory dir do
    action :create
    recursive true
    owner tomcat_user
    group tomcat_group
    mode "0700"
  end
end


script "install_base_etc" do
  not_if { Dir.entries(tomcat_conf).length > 0 }
  interpreter "bash"
  user "root"
  cwd tomcat_base
  code <<-EOH
    cp -r #{tomcat_home}/conf .
    chown -R #{tomcat_user}:#{tomcat_group} conf
  EOH
end

bash "install_extras" do
  #not_if { Dir.entries(tomcat_lib).length > 0 }
  user "root"
  cwd "#{tomcat_lib}"
  code <<-EOH
      cp #{tomcat_extras}/*.jar .
      chown root:#{tomcat_group} *.jar
  EOH
end


template "#{tomcat_conf}/catalina.properties" do
  source "catalina.properties.erb"
  group tomcat_group
  owner "root"
  mode 0640
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_conf}/logging.properties" do
  source "logging.properties.erb"
  group tomcat_group
  owner "root"
  mode 0640
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_conf}/tomcat.conf" do
  source "tomcat.conf.erb"
  group tomcat_group
  owner "root"
  mode 0640
  variables script_vars
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_conf}/tomcat-users.xml" do
  source "tomcat-users.xml.erb"
  group tomcat_group
  owner "root"
  mode 0640
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_conf}/server.xml" do
  source "server.xml.erb"
  group tomcat_group
  owner "root"
  mode 0640
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_conf}/context.xml" do
  source "context.xml.erb"
  group tomcat_group
  owner "root"
  mode 0640
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_conf}/web.xml" do
  source "web.xml.erb"
  group tomcat_group
  owner "root"
  mode 0640
  notifies :restart, "service[#{tomcat_service}]"
end


script "install_manager" do
  not_if { File.exists?("#{tomcat_webapps}/manager") }
  interpreter "bash"
  user "root"
  cwd tomcat_webapps
  code <<-EOH
    cp -r #{tomcat_home}/webapps/manager .
  EOH
  notifies :restart, "service[#{tomcat_service}]"
end

template "#{tomcat_webapps}/manager/META-INF/context.xml" do
    source "manager.xml.erb"
    group tomcat_group
    owner "root"
    mode 0640
    notifies :restart, "service[#{tomcat_service}]"
    #notifies :restart, resources(:service => "tomcat"), :delayed
end


template tomcat_script do
    source "tomcat.sh.erb"
    mode 0755
    owner "root"
    group "root"
    variables script_vars
    notifies :restart, "service[#{tomcat_service}]"
end


template tomcat_launcher do
    source "tomcatd.sh.erb"
    mode 0755
    owner "root"
    group "root"
    variables script_vars
    notifies :restart, "service[#{tomcat_service}]"
end

node[:apps][:profiles].each do |app|
    tomcat_app "#{app[:name]}" do
        artifact_resolver   app[:resolver]
        resolver_params     app[:resolver_params]

        enabled             app[:enabled]
        app_group_id        app[:group_id]
        app_artifact_id     app[:artifact_id]
        app_version         app[:version]
        app_context         app[:context]
        app_remote_base     app[:remote_base]


        tomcat_service tomcat_service
        tomcat_group tomcat_group
        tomcat_user tomcat_user
        tomcat_webapps tomcat_webapps

        apps_artifact_archive node[:apps][:artifact_archive]
        apps_staged_archive node[:apps][:staged_archive]
    end
end


service tomcat_service do
    case node[:platform]
    when "centos"
      service_name tomcat_service
    else
      name tomcat_service
    end
    supports :start => true, :stop => true, :restart => true, :status => true
    action [:enable, :start]
end
