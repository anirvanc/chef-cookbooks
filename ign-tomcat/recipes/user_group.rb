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

# Defines the Tomcat User Group either through direct assigment using the node[:tomcat][:users][:group] or a 
# _Data_Bag_ defined inside the `data_bags/groups/<group_data_bag>.json` Bag Item.
#
# Used Attributes:
#   * node[:tomcat][:users][:group] => Defines the Tomcat User Group Name
#   * node[:tomcat][:users][:group_data_bag] => Defines the name of the Data Bag Item inside the Group Data Bag
#
# Will raise exceptions if 
#   * The _Data_Bag_ nor _group_ are defined.
#   * If its not able to resolve a group.
#
# Set Attributes.
#   * node[:tomcat][:group] => The Resolved Tomcat Group 
#--
# TODO: 
# 
#++
#

manage_users = node[:tomcat][:users][:manage]

tomcat_group_db_name = node[:tomcat][:users][:group_data_bag]
tomcat_group         = node[:tomcat][:users][:group]
raise "We need either tomcat[:users][:group] or tomcat[:users][:group_data_bag]" if tomcat_group_db_name.nil? && tomcat_group.nil? 


# See if we have a Data_Bag that we need to use.
if tomcat_group_db_name.nil?

    if manage_users
      group(tomcat_group) do
        action :create
      end
    else
        log "#{tomcat_group} will not be managed."
    end

    log "tomcat/group set to #{tomcat_group}"
    node[:tomcat][:group] = tomcat_group

else
    log "Expecting group #{tomcat_group_db_name} to be defined in Data_Bag 'groups'"
    tomcat_group_details = data_bag_item("#{tomcat_group_db_name}", "#{tomcat_group}")

    raise "Unable to find databag for group #{tomcat_group_db_name}" if tomcat_group_details.nil?

    tomcat_group     = tomcat_group_details['id']
    tomcat_group_gid = tomcat_group_details['gid']

    log "Group #{tomcat_group_details}[#{tomcat_group}, #{tomcat_group_gid}]"

    if manage_users
        group(tomcat_group) do
            action :create
            gid tomcat_group_gid
        end
    else
      log "#{tomcat_group} will not be managed."
    end

  
    log "tomcat/group set to #{tomcat_group}"
    node[:tomcat][:group] = tomcat_group


end

# We assert the expectation 
raise "We were unable to resolve the Tomcat Group ( node[:tomcat][:group] )." if node[:tomcat][:group].nil? 
