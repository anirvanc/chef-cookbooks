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

# Defines and deploys an Application, represented by an Artifact, to a given Tomcat Instance.
#
#
# Parameters:
#   *:enabled                 Establishes if the Application should be enabled or desabled. If the application is disabled it will be downloaded and staged but not deployed. Value defaults => true.
#   *:tomcat_service          Name of the _tomcat_service_ that needs to be restarted, defaults=> "tomcat-default"
#   *:tomcat_group            Name of the Tomcat User Group, defaults => "tomcat"
#   *:tomcat_user             Name of the Tomcat User, defaults => "tomcat-default"
#   *:tomcat_webapps          Path of the WebApp directory where we are going to deploy the application, defaults => "/etc/tomcat/default/webapps"
#   *:artifact_resolver       Identifies the Artifact Resolver, as of now we only support either :default or :nexus. Defaults to => :default
#   *:app_group_id            The Group Identifier of the Artifact, defaults => "default_group"
#   *:app_artifact_id         The Artifact Identifier, defaults => "default-app"
#   *:app_version             The Artifact Version => "1.0"
#   *:app_type                The Artifact Type => "war"
#   *:app_context             The Context where the Application will be deployed to, defaults => "default-app#v3"
#   *:app_remote_base         The Remote Base used by the Resolver, depends on each resolver but its usually a URL
#   *:apps_artifact_archive   The Location where we are going to store the downloaded/copied Artifacts, defaults => "/srv/tomcat/archive"
#   *:apps_staged_archive     The Location where we are going to stage the downloaded/copied Artifacts for deployment, defautls => "/srv/tomcat/staged"
#   *:resolver_params         A map used by the Artifact Resolver that might contain additional parameters, defults=> {}
#  
# == Artifact Resolvers ==
# The _Artifact Resolvers_ define the steps that need to occure to fetch an Artifact according to the:
#   * app_group_id e.g. com.my.company
#   * app_artifact_id e.g my-app
#   * app_version e.g. 1.0-M1
#
# As of now we only support two resolvers..
#   * :default .- See Definition default_resolver.rb
#   * :nexus   .- See Definition nexus_resolver.rb
#
# Note: You can also define the *app_type* but since Tomcat is a WebContainer you shouldn't have to change this since it defaults to *war*.
#
#--
# TODO: 
# 
#++
# 

define :tomcat_app,
       :enabled                 => true,
       :tomcat_service          => "tomcat-default",
       :tomcat_group            => "tomcat",
       :tomcat_user             => "tomcat-default",
       :tomcat_webapps          => "/etc/tomcat/default/webapps",
       :artifact_resolver       => :default,
       :app_group_id            => "default_group",
       :app_artifact_id         => "default-app",
       :app_version             => "1.0",
       :app_type                => "war",
       :app_context             => "default-app#v3",
       :app_remote_base         => "",
       :apps_artifact_archive   => "/srv/tomcat/archive",
       :apps_staged_archive     => "/srv/tomcat/staged",
       :resolver_params         => {} do

    tomcat_service = params[:tomcat_service]
    raise "Undefined :tomcat_service" if tomcat_service.nil?

    tomcat_group   = params[:tomcat_group]
    tomcat_user    = params[:tomcat_user]
    tomcat_webapps = params[:tomcat_webapps]

    apps_artifact_archive = params[:apps_artifact_archive]
    apps_staged_archive   = params[:apps_staged_archive]

    app_remote_base   = params[:app_remote_base]
    app_group_id      = params[:app_group_id]
    app_artifact_id   = params[:app_artifact_id]
    app_version       = params[:app_version]

    app_artifact_name = "#{app_artifact_id}-#{app_version}"
    app_artifact_file = "#{app_artifact_name}.#{params[:app_type]}"
    app_artifact_dir  = "#{apps_artifact_archive}/#{app_artifact_id}"
    app_staged_dir    = "#{apps_staged_archive}/#{app_artifact_id}"


    app_context  = if params[:app_context] then params[:app_context] else app_artifact_name end

    directory app_artifact_dir do
        action :create
        recursive true
        owner 'root'
        group tomcat_group
        mode "0750"
    end

    resolver = if params[:artifact_resolver] then params[:artifact_resolver] else :default end
    log "Using artifact resolver #{resolver} for #{app_artifact_file}"

    case "#{resolver}"
    when "default" then 
        default_resolver "default_resolver" do
            remote_base         app_remote_base
            tomcat_service      tomcat_service
            tomcat_group        tomcat_group
            artifact_file       app_artifact_file
            artifact_dir        app_artifact_dir
            app_group_id        app_group_id
            app_artifact_id     app_artifact_id
            app_version         app_version
        end

    when "nexus" then
        
        repository_id = if params[:resolver_params] then params[:resolver_params][:repository_id] end

        nexus_resolver "nexus_resolver" do
            remote_base         app_remote_base
            repository_id       repository_id
            tomcat_service      tomcat_service
            tomcat_group        tomcat_group
            artifact_file       app_artifact_file
            artifact_dir        app_artifact_dir
            app_group_id        app_group_id
            app_artifact_id     app_artifact_id
            app_version         app_version
        end

    else raise "Resolver #{resolver} is not yet supported."
    end

    log("#{app_artifact_name} enabled[#{params[:enabled]}]..")

    if params[:enabled]
        unless File.exists?("#{app_staged_dir}/#{app_artifact_name}")

          directory "#{app_staged_dir}/#{app_artifact_name}" do
            action :delete
          end

          directory "#{app_staged_dir}/#{app_artifact_name}" do
            action :create
            recursive true
            owner tomcat_user
            group tomcat_group
            mode "0550"
          end

          script "install_app" do
            interpreter "bash"
            user "root"
            cwd "#{app_staged_dir}/#{app_artifact_name}"
            code <<-EOH
            cp "#{app_artifact_dir}/#{app_artifact_file}" .
            jar xvf "#{app_artifact_file}"
            rm  "#{app_artifact_file}"
            EOH
          end
        end


        link "#{tomcat_webapps}/#{app_context}" do
          to "#{app_staged_dir}/#{app_artifact_name}"
          action :create
          owner tomcat_user
          group tomcat_group
          notifies :restart, "service[#{tomcat_service}]"
        end

    else
        if  File.exist?("#{tomcat_webapps}/#{app_context}")
          link "#{tomcat_webapps}/#{app_context}" do
            to "#{app_staged_dir}/#{app_artifact_name}"
            action :delete
            owner tomcat_user
            group tomcat_group
            notifies :restart, "service[#{tomcat_service}]"
          end
        end
    end

end
