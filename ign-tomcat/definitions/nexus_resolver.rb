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

# 
# Based on the Nexus Redirect API. 
# http://maven.ign.com/nexus/service/local/artifact/maven/redirect?g=com.ign&a=orinoco&v=3.0.4-SNAPSHOT&r=snapshots&e=war
#--
# TODO: 
# Download the artifact only if it was changed.
#++
# What I return
define  :nexus_resolver,
        :remote_base        => "",
        :repository_id      => "",
        :tomcat_service     => "",
        :tomcat_group       => "",
        :artifact_dir       => "",
        :artifact_file      => "",
        :app_group_id       => "",
        :app_artifact_id    => "", 
        :app_version        => "",
        :app_type           => "war",
        :nexus_endpoint     => "service/local/artifact/maven/redirect",
do

  nexus_endpoint    = params[:nexus_endpoint]

  remote_base       = params[:remote_base]
  raise "Argument :remote_base is required." if remote_base.nil? 
  
  app_group_id      = params[:app_group_id]
  raise "Argument :app_group_id is required." if app_group_id.nil? 

  app_artifact_id   = params[:app_artifact_id]
  raise "Argument :app_artifact_id is required." if app_artifact_id.nil? 

  app_version       = params[:app_version]
  raise "Argument :app_version is required." if app_version.nil? 

  repo_id           = unless params[:repository_id].nil? 
                          params[:repository_id]
                      else
                          if /SNAPSHOT/.match(app_version).nil? then "releases" else "snapshots" end
                      end

  log "Repository ID set to [#{repo_id}]."

  app_artifact_url  = "#{remote_base}/#{nexus_endpoint}?r=#{repo_id}&g=#{app_group_id}&a=#{app_artifact_id}&v=#{app_version}&e=#{params[:app_type]}"

  log "Nexus Resolver Query #{app_artifact_url}"

  remote_file "#{params[:artifact_dir]}/#{params[:artifact_file]}" do
    source  "#{app_artifact_url}"
    # see how can i lazy-load the file, failing when loading the recipe since the file is not yet there.
    #checksum File.open("#{app_artifact_dir}/#{app_artifact}.md5").gets
    action  :create_if_missing
    owner   'root'
    group   params[:tomcat_group]
    mode    "0640"
  end


  #tomcat_service = params[:tomcat_service]
=begin

    remote_file "/tmp/couch.png" do
      source "http://couchdb.apache.org/img/sketch.png"
      action :nothing
    end
 
    http_request "HEAD #{http://couchdb.apache.org/img/sketch.png}" do
      message ""
      url http://couchdb.apache.org/img/sketch.png
      action :head
      if File.exists?("/tmp/couch.png")
        headers "If-Modified-Since" => File.mtime("/tmp/couch.png").httpdate
      end
      notifies :create, resources(:remote_file => "/tmp/couch.png"), :immediately
    end

=end

end
