# encoding: UTF-8
#
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

#-----------------------------------------------------------------------------------------------------------------------
# Setting up CATALINA HOME
# Todo: move the logic that deals with downloading and installing the distro to its own recipe named install_distro,
# and call it through `include_recipe "ign-tomcat::install_distro"`

user = 'root'
group = 'root'

tomcat_version          = node[:tomcat][:version]
tomcat_version_name     = "apache-tomcat-#{tomcat_version}"
tomcat_version_name_tgz = "#{tomcat_version_name}.tar.gz"

# Directory creation.
tomcat_archive          = node[:tomcat][:archive]
tomcat_home             = node[:tomcat][:home]
tomcat_local_path       = "#{tomcat_archive}/#{tomcat_version_name}"

tomcat_distro_path      = node[:tomcat][:distro]
tomcat_distro_full_path = "#{tomcat_distro_path}/#{tomcat_version_name_tgz}"
tomcat_distro_extras    = "#{tomcat_distro_path}/extras"

node[:tomcat][:extras]  = tomcat_distro_extras

[tomcat_archive, tomcat_distro_path, tomcat_distro_extras].each do |dir|
  directory dir do
    action :create
    recursive true
    mode 0755
    owner user
    group group
  end
end


remote_file "#{tomcat_distro_full_path}.md5" do
  source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcat_version}/bin/#{tomcat_version_name_tgz}.md5"
  mode "0644"
  action :create_if_missing
end
remote_file "#{tomcat_distro_full_path}" do
  source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcat_version}/bin/#{tomcat_version_name_tgz}"
  mode "0644"
  #Checksum uses SHA1 and we only have the MD5 from apache.
  #checksum File.new("#{tomcat_distro_full_path}.md5").gets.split[0]
  action :create_if_missing
end
remote_file "#{tomcat_distro_extras}/tomcat-juli.jar" do
  source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcat_version}/bin/extras/tomcat-juli.jar"
  mode "0644"
  action :create_if_missing
end
remote_file "#{tomcat_distro_extras}/tomcat-juli-adapters.jar" do
  source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcat_version}/bin/extras/tomcat-juli-adapters.jar"
  mode "0644"
  action :create_if_missing
end
remote_file "#{tomcat_distro_extras}/catalina-ws.jar" do
  source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcat_version}/bin/extras/catalina-ws.jar"
  mode "0644"
  action :create_if_missing
end
remote_file "#{tomcat_distro_extras}/catalina-jmx-remote.jar" do
  source "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tomcat_version}/bin/extras/catalina-jmx-remote.jar"
  mode "0644"
  action :create_if_missing
end


bash "install_tomcat_to_local" do
  user 'root'
  not_if do
    ::File.exists?(tomcat_local_path)
  end

  cwd tomcat_archive

  code <<-EOH
    cp #{tomcat_distro_full_path} .
    tar -zxf #{tomcat_version_name_tgz}
    rm #{tomcat_version_name_tgz}
  EOH
end

log "Linking #{tomcat_archive}/#{tomcat_version_name} to current"
link tomcat_home do
  to "#{tomcat_archive}/#{tomcat_version_name}"
  action :create
  owner user
  group group
end


