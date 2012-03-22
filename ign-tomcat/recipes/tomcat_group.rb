# encoding: UTF-8
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

# What I do
# 
#--
# TODO: 
# 
#++
# What I return

#Todo: move to an internal tomcat_user recipe
tomcat_group_db_name = node[:tomcat][:users][:group_data_bag]
tomcat_group         = node[:tomcat][:users][:group]
raise "We need either tomcat[:users][:group] or tomcat[:users][:group_data_bag]" if tomcat_group_db_name.nil? && tomcat_group.nil? 


# Create the group,
if tomcat_group_db_name.nil?

  group(tomcat_group) do
    action :create
  end

else
  log "Expecting group #{tomcat_group_db_name} to be defined in Data_Bag 'groups'"
  tomcat_group_details = data_bag_item('groups', "#{tomcat_group_db_name}")
  #tomcat_group_details = data_bag_item('groups', 'tomcat')

  raise "Unable to find databag for group #{tomcat_group_db_name}" if tomcat_group_details.nil?

  tomcat_group     = tomcat_group_details['id']
  tomcat_group_gid = tomcat_group_details['gid']

  log "Group #{tomcat_group_details}[#{tomcat_group}, #{tomcat_group_gid}]"

  group(tomcat_group) do
    action :create
    gid tomcat_group_gid
  end
  node[:tomcat][:group] = tomcat_group


end

# We assert the expectation 
raise "We were unable to resolve the Tomcat Group ( node[:tomcat][:group] )." if node[:tomcat][:group].nil? 
