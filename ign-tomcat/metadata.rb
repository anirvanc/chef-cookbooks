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

maintainer          "IGN Entertainment, Inc."
maintainer_email    "linuxops@ign.com"
license             "Apache v2.0"
description         "Installs and configures all aspects of Tomcat7 using custom local installation. Refere to the README.md file for a detailed description."
long_description    IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version             "0.1.1"
recipe              "ign-tomcat", "IGN Tomcat7 Recipe"

#supports 'ubuntu','centos','redhat','debian'

depends "java"

attribute "tomcat/version",
    :display_name   => "Tomcat Distribution Version",
    :required       => "optional",
    :default        => "7.0.25"

#attribute "tomcat/with_native",
#    :display_name   => "Tomcat Native Support is not yet available with this recipe.",
#    :required       => "optional",
#    :default        => "false"

attribute "tomcat/java_home",
    :display_name   => "Java Home",
    :required       => "optional",
    :default        => "/usr/java/default"

attribute "tomcat/distro",
    :display_name   => "Tomcat Distribution Directory",
    :description    => "Directory that can be used to provide a local binary, gzip Tomcat Distribution. If the distrubition is not available it will be downloaded.",
    :required       => "optional",
    :default        => "/tmp/archive/tomcat"

attribute "tomcat/instance",
    :display_name   => "Name of the Tomcat Instance (CATALINA_BASE)",
    :description    => "Name used for the Tomcat Instance, you usually want to give a different name that makes sense to you and your team.",
    :required       => "recommended",
    :default        => "default"

attribute "tomcat/users/group", 
    :display_name   => "Tomcat Instance User Group Name",
    :description    => "Name of the User Group for the given Tomcat Instance (CATALINA_BASE) or the name of the Group Data Bag Item if a tomcat/users/group_data_bag is defined.",
    :required       => "optional",
    :default        => "tomcat"

attribute "tomcat/users/user",
    :display_name   => "Tomcat Instance User Group Name",
    :description    => "Name of the User for the given Tomcat Instance (CATALINA_BASE) or the name of the User Data Bag Item if a tomcat/users/users_data_bag is defined.",
    :required       => "optional",
    :default        => "tc-<tomcat/instance>"

attribute "tomcat/users/group_data_bag",
    :display_name   => "User Group Data Bag Name",
    :description    => "The name of the Group Data Bag that will be used to resolve the User Group Name Data Bag Item (Item name is defined by the tomcat/users/group attribute).",
    :required       => "optional",
    :defaults       => nil

attribute "tomcat/users/users_data_bag",
    :display_name   => "User Data Bag Name",
    :description    => "The name of the Users Data Bag that will be used to resolve the User Name Data Bag Item (Item name is defined by the tomcat/users/user attribute).",
    :required       => "optional",
    :defaults       => nil

attribute "tomcat/users/manage",
    :display_name   => "Enable User Group and User Creation",
    :description    => "Enables or disables the creation of the User Group and User. Note that if you set the flag to false you need to make sure the User Group (tomcat/users/group) and User (tomcat/users/user) are defined prior the execution of the recipe.",
    :required       => "optional",
    :defaults       => true

attribute "tomcat/logs_path",
    :display_name   => "Base Directory for the Tomcat Instance (CATALINA BASE) Logs",
    :description    => "Base Directory for the Tomcat Instance (CATALINA BASE) Logs Directory e.g. for /var/log/tomcat => /var/log/tomcat/tc-default/catalina.out ",
    :required       => "optional",
    :defaults       => "/var/log/tomcat"

attribute "tomcat/temp_path",
    :display_name   => "Base Directory for the Tomcat Instance (CATALINA BASE) Temp Directory",
    :required       => "optional",
    :defaults	    => "/var/tmp/tomcat"

attribute "tomcat/base_path",
    :display_name   => "Base Directory for the Tomcat Instance (CATALINA BASE) Directory",
    :description    => "Base Directory for the Tomcat Instance (CATALINA BASE) Directory e.g. for /etc/tomcat => /etc/tomcat/tc-default/conf/server.xml",
    :required       => "optional",
    :defaults       => "/etc/tomcat"

attribute "tomcat/ajp_port",
    :display_name   => "Tomcat Instance AJP Port",
    :required       => "optional",
    :defaults   	=> 8009

attribute "tomcat/http_port",
    :display_name   => "Tomcat Instance HTTP Port",
    :required       => "optional",
    :defaults       => 8080

attribute "tomcat/redirect_port",
    :display_name   => "Tomcat Instance Redirect Port",
    :required       => "optional",
    :defaults       => 8443

attribute "tomcat/shutdown_port",
    :display_name   => "Tomcat Instance Shutdown Port",
    :required       => "optional",
    :defaults       => 8005

attribute "tomcat/with_snmp",
    :display_name   => "Enable JVM SNMP",
    :description    => "SNMP only works with the Oracle JDK and not the Open JDK",
    :required       => "optional",
    :defaults       => false

attribute "tomcat/snmp_port",
    :display_name   => "Tomcat Instance JVM SNMP Port",
    :required       => "optional",
    :defaults	    => 1161

attribute "tomcat/snmp_interface",
    :display_name   => "Tomcat Instance JVM SNMP Bind Interface",
    :description    => "Defines the Network Interface that will be used to bind the JVM SNMP Service, 0.0.0.0 sets it to all.",
    :required       => "optional",
    :defaults       => "0.0.0.0"

attribute "tomcat/shutdown_wait",
    :display_name   => "Second Resolution Timer for Tomcat Instance Shutdown",
    :description    => "The amount of time, in seconds, that we will wait for a Tomcat Instance shutdown before we kill the process.",
    :required       => "optional",
    :defaults	    => 3

attribute "tomcat/jvm_route",
    :display_name   => "Tomcat Instance JVM Route",
    :required       => "optional",
    :defaults	    =>"jvm-<tomcat/instance]>"

attribute "tomcat/java_opts",
    :display_name   => "JVM Options",
    :description    => "Read the README.md for more details. Please take into account the Java Version and refer to http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html",
    :required       => "optional"

attribute "tomcat/java/xopt/min_factor",
    :description    => "Specifies the -Xminf for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :defaults       => 0.5

attribute "tomcat/java/xopt/max_factor",
    :description    => "Specifies the -Xmaxf for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :defaults       => 0.9

attribute "tomcat/java/xopt/min_heap",
    :description    => "Specifies the -Xms for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :defaults       => "64m"

attribute "tomcat/java/xopt/max_heap",
    :description    => "Specifies the -Xmx for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :default        => "512m"

attribute "tomcat/java/xopt/max_perm",
    :description    => "Specifies the -XX:MaxPermSize for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :default        => "96m"

attribute "tomcat/java/locale/user_lang",
    :description    => "Specifies the -Duser.language for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :default        => "en"

attribute "tomcat/java/locale/user_country",
    :description    => "Specifies the -Duser.country for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :default        => "US"

attribute "tomcat/java/run_mode",
    :display_name   => "Custom Run Mode Flag",
    :description    => "Specifies the -Drun.mode for the JVM. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :defaults	    => "production"

attribute "tomcat/java_agent",
    :description    => "Used to pass a set of Java Agents. This attribute will be ignored if you override the tomcat/java_opts",
    :required       => "optional",
    :defaults	    => ""


attribute "tomcat/catalina_opts",
    :display_name   => "Tomcat Instance Catalina Options",
    :description    => "Used to provide additional Catalina Options",
    :required       => "optional",
    :defaults	    => ""

attribute "apps/profiles",
    :display_name   => "Application Profiles",
    :type           => "array",
    :defaults	    => nil,
    :description    => "Read the README.md file for a detail description odn Application Profiles"
