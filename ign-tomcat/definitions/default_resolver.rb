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
#--
# TODO: 
# Download the artifact only if it was changed.
#++
# What I return
define  :default_resolver,
        :remote_base        => "",
        :tomcat_service     => "",
        :tomcat_group       => "",
        :artifact_dir       => "",
        :artifact_file      => "",
        :app_group_id       => "",
        :app_artifact_id    => "",
        :app_version        => "",
        :app_type           => "war",
do
    remote_base   = params[:remote_base]

    tomcat_service  = params[:tomcat_service]

    tomcat_group    = params[:tomcat_group]

    artifact_dir    = params[:artifact_dir]

    artifact_file   = params[:artifact_file]

    app_group_id      = params[:app_group_id]

    app_artifact_id   = params[:app_artifact_id]

    app_version       = params[:app_version]


    remote_app_artifact  = "#{app_artifact_id}-#{app_version}.#{params[:app_type]}"
    app_group_url        = "#{app_group_id}".gsub('.', '/')
    app_artifact_url     = "#{remote_base}/#{app_group_url}/#{app_artifact_id}/#{app_version}/#{remote_app_artifact}"

    log "App Artifact URL is #{app_artifact_url}"

    remote_file "#{artifact_dir}/#{artifact_file}.sha1" do
        source "#{app_artifact_url}.sha1"
        action :create_if_missing
        owner  'root'
        group  tomcat_group
        mode "0440"
    end

    remote_file "#{artifact_dir}/#{artifact_file}.md5" do
        source "#{app_artifact_url}.md5"
        action :create_if_missing
        owner  'root'
        group  tomcat_group
        mode "0440"
    end

    remote_file "#{artifact_dir}/#{artifact_file}" do
        source  "#{app_artifact_url}"
        # see how can i lazy-load the file, failing when loading the recipe since the file is not yet there.
        #checksum File.open("#{app_artifact_dir}/#{app_artifact}.md5").gets
        action  :create_if_missing
        owner   'root'
        group   tomcat_group
        mode    "0640"
    end

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
