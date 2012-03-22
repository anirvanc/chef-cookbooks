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

# Defines the Tomcat User either through direct assigment using..
#   * The node[:tomcat][:users][:user] attribute.
#   * The Data Bag defined by node[:tomcat][:users][:users_data_bag] where the Item is defined by node[:tomcat][:users][:user]
#   * The Data Bag defined by node[:tomcat][:users][:users_data_bag] where the Item is defined by "tomcat-#{node[:tomcat][:instance]}"
#
# Used Attributes:
#   * node[:tomcat][:users][:user] => Defines the Tomcat User Name or Data Bag Item name if a Data Bag is available.
#   * node[:tomcat][:users][:users_data_bag] => Defines the name of the Tomcat Users Data Bag 
#
# Will raise exceptions if 
#   * The _Data_Bag_ nor a _user_ is defined.
#   * If its not able to resolve a _user_.
#
# Set Attributes.
#   * node[:tomcat][:user] => The Resolved Tomcat User
#--
# TODO: 
# 
#++
# 

include_recipe "ign-tomcat::user_group"

group = node[:tomcat][:group]

manage_users = node[:tomcat][:users][:manage]

tomcat_users_db_name = node[:tomcat][:users][:users_data_bag]
tomcat_user          = node[:tomcat][:users][:user]
raise "We need either tomcat[:users][:user] or tomcat[:users][:users_data_bag]" if tomcat_users_db_name.nil? && tomcat_user.nil? 


if tomcat_users_db_name.nil?
    raise "No Tomcat Group defined (node[:tomcat][:group])" if group.nil?
    
    if manage_users 
        user(tomcat_user) do
            gid group
            shell "/bin/bash"
        end
    else 
        log "#{tomcat_user} will not be managed"
    end

    node[:tomcat][:user] = tomcat_user

else
  log "Expecting user #{tomcat_user} to be defined in Data_Bag #{tomcat_users_db_name}"
  # Load the keys of the items in the 'admins' data bag
  tomcat_user_details = data_bag_item("#{tomcat_users_db_name}", "#{tomcat_user}")
  #tomcat_user_details = data_bag_item('tomcat-users', 'tomcat-app')

  raise "Unable to find databag #{tomcat_users_db_name} for user #{tomcat_user}" if tomcat_user_details.nil?
  tomcat_user = tomcat_user_details['id']

  group = if tomcat_user_details['gid'] then tomcat_user_details['gid'] else group end
  raise "No Tomcat Group defined (node[:tomcat][:group] || gid in Data_Bag #{tomcat_user})" if group.nil?

  if manage_users
      user(tomcat_user) do
        uid tomcat_user_details['uid']
        gid group
        shell tomcat_user_details['shell']
        comment tomcat_user_details['comment']
        home tomcat_user_details['home']
        supports :manage_home => true
      end
  else
      log "#{tomcat_user} will not be managed"
  end
  node[:tomcat][:user] = tomcat_user
end

raise "We were unable to resolve the Tomcat User ( node[:tomcat][:user] )." if node[:tomcat][:user].nil? 


