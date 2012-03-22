Description
===========

This is our IGN Tomcat7 Recipe, we use it to

0.  Install Tomcat7 Distributions, i.e. the *CATALINA_HOME*.
0.  Install Tomcat Instances, i.e. the *CATALINA_BASEs*, for our Java|Scala Based Services.
0.  Deploy Applications, named _Application Profiles_ in the recipe, from different sources. E.g Recipe File, Remote URLs and a Nexus Server.


This recipe sets up its customized *JAVA_OPT*, please refer to the *tomcat/java_opts* for more details.

Requirements
============

Java JDK, checkout the *tomcat/java_home* attribute if your *JAVA_HOME* doesn't match "/usr/java/default".

Attributes
==========

## tomcat/version
   
Stands for the *Tomcat Distribution Version*.
_Optional_, defaults to "7.0.25"

## tomcat/java_home
   
The Java Home used by the *Tomcat Instance*.
_Optional_, defaults to "/usr/java/default"

## tomcat/distro
   
The directory that stores the *Tomcat Distribution*. If the distribution is already in the directory it will be used else it will be downloaded from the official Tomcat Repository at http://archive.apache.org/dist/tomcat/tomcat-7 .
_Optional_, defaults to "/tmp/archive/tomcat"

## tomcat/instance
    
The name given to the Tomcat Instance (CATALINA_BASE), you usually want to give a different name that makes sense to you and your team.
_Recommended_, defaults to "default"

## tomcat/users/group
    
Name of the User Group for the given Tomcat Instance (CATALINA_BASE) or the name of the Group Data Bag Item if a tomcat/users/group_data_bag is defined.
_Optional_, defaults to "tomcat"

## tomcat/users/user
    
Name of the User for the given Tomcat Instance (CATALINA_BASE) or the name of the User Data Bag Item if a tomcat/users/users_data_bag is defined.
_Optional_, defaults to "tc-<tomcat/instance>"

## tomcat/users/group_data_bag
    
The name of the Group Data Bag that will be used to resolve the User Group Name Data Bag Item (Item name is defined by the tomcat/users/group attribute).
_Optional_, defaults to nil

## tomcat/users/users_data_bag
    
The name of the Users Data Bag that will be used to resolve the User Name Data Bag Item (Item name is defined by the tomcat/users/user attribute).
_Optional_, defaults to nil

## tomcat/users/manage
    
Enables or disables the creation of the User Group and User. Note that if you set the flag to false you need to make sure the User Group (tomcat/users/group) and User (tomcat/users/user) are defined prior the execution of the recipe.
_Optional_, defaults to true

## tomcat/logs_path
    
Base Directory for the Tomcat Instance (CATALINA BASE) Logs Directory e.g. for a value `/var/log/tomcat` with an _Instance Name_ of *default* we will output to `/var/log/tomcat/default/catalina.out` .
_Optional_, defaults to "/var/log/tomcat"

## tomcat/temp_path
    
Base Directory for the Tomcat Instance (CATALINA BASE) Temp Directory
_Optional_, defaults to "/var/tmp/tomcat"

## tomcat/base_path
    
Base Directory for the Tomcat Instance (CATALINA BASE) Directory e.g. for /etc/tomcat => /etc/tomcat/tc-default/conf/server.xml
_Optional_, defaults to "/etc/tomcat"

## tomcat/ajp_port
    
Tomcat Instance AJP Port
_Optional_, defaults to 8009

## tomcat/http_port
    
Tomcat Instance HTTP Port
_Optional_, defaults to 8080

## tomcat/redirect_port
    
Tomcat Instance Redirect Port
_Optional_, defaults to 8443

## tomcat/shutdown_port
    
Tomcat Instance Shutdown Port
_Optional_, defaults to 8005

## tomcat/with_snmp
    
Enable JVM SNMP. SNMP only works with the Oracle JDK and not the Open JDK
_Optional_, defaults to false

## tomcat/snmp_port
    
Tomcat Instance JVM SNMP Port
_Optional_, defaults to 1161

## tomcat/snmp_interface
    
Tomcat Instance JVM SNMP Bind Interface, it defines the Network Interface that will be used to bind the JVM SNMP Service, 0.0.0.0 sets it to all.
_Optional_, defaults to "0.0.0.0"

## tomcat/shutdown_wait
    
The amount of time, in seconds, that we will wait for a Tomcat Instance shutdown before we kill the process.
_Optional_, defaults to 3

## tomcat/jvm_route
    
Tomcat Instance JVM Route
_Optional_, defaults to "jvm-<tomcat/instance]>"

## tomcat/java_opts
    
JVM Options, please take into account the Java Version and refer to http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html
_Optional_,  defaults to the template bellow. *Note*, in the template `tomcat` stands for `node[:tomcat]`.

```
    #{tomcat[:java_agent]}
      -Xms#{tomcat[:java][:xopt][:min_heap]} -Xmx#{tomcat[:java][:xopt][:max_heap]} -XX:MaxPermSize=#{tomcat[:java][:xopt][:max_perm]}
      -Xminf#{tomcat[:java][:xopt][:min_factor]} -Xmaxf#{tomcat[:java][:xopt][:max_factor]}
      -XX:-UseParallelGC -XX:+AggressiveOpts -XX:+UseStringCache -XX:+UseCompressedStrings -XX:+OptimizeStringConcat
      -XX:ErrorFile=#{tomcat[:temp]}/hs_err_pid.log -XX:HeapDumpPath=#{tomcat[:temp]}/java_pid.hprof
      -XX:-HeapDumpOnOutOfMemoryError -XX:+AlwaysPreTouch
      -Duser.language=#{tomcat[:java][:locale][:user_lang]} -Duser.country=#{tomcat[:java][:locale][:user_country]}
      -Drun.mode=#{tomcat[:java][:run_mode]}

```

## tomcat/java/xopt/min_factor
    
Specifies the -Xminf for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to 0.5

## tomcat/java/xopt/max_factor
    
Specifies the -Xmaxf for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to 0.9

## tomcat/java/xopt/min_heap
    
Specifies the -Xms for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to "64m"

## tomcat/java/xopt/max_heap
    
Specifies the -Xmx for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to "512m"

## tomcat/java/xopt/max_perm
    
Specifies the -XX:MaxPermSize for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to "96m"

## tomcat/java/locale/user_lang
    
Specifies the -Duser.language for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to "en"

## tomcat/java/locale/user_country
    
Specifies the -Duser.country for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to "US"

## tomcat/java/run_mode
    
Specifies the -Drun.mode for the JVM. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to "production"

## tomcat/java_agent
    
Used to pass a set of Java Agents. This attribute will be ignored if you override the tomcat/java_opts
_Optional_, defaults to ""


## tomcat/catalina_opts
    
Used to provide additional Catalina Options
_Optional_, defaults to ""

## apps/profiles
    
Defines an array of _Apllication Profiles_ that get deployed to the given Tomcat Instance. The Profile Includes:

* :remote_base  .- Base URI that will be used to resolve the artifact. If empty it will resolve to a Cookbook File. 
* :artifact_id  .- Defines the Artifact Identifier (The artifactId is generally the name that the project is known by). Refer to http://maven.apache.org/guides/mini/guide-naming-conventions.html for more details.
* :group_id     .- Namespace that Identifies the Artifact. Refer to http://maven.apache.org/guides/mini/guide-naming-conventions.html for more details.
* :version      .- Version of the Artifact. Refer to http://maven.apache.org/guides/mini/guide-naming-conventions.html
* :context      .- Context that will host the Application.
* :enabled      .- Flag that tells if an application should be deployed or not. If false the application will be staged but not deployed.
* :resolver     .- Defines the strategy that should be used to resolve and provide the Artifact. As of now we only support two, defaults and :nexus. Bellow you will find some details regarding Resolvers.

Example of an apps/profiles (this is the default value):

```ruby
[
    {
        :artifact_id    => "demo-app"
        :group_id       => "demo-group"
        :version        => "1.0"
        :context        => "demo"
        :enabled        => true
    }
]
```


Example of an apps/profiles using the defaults resolver and :nexus . Note that the files are downloaded from the given remote_base.

```ruby
[
    {
          :group_id     => "com.ign"
          :artifact_id  => "orinoco"
          :version      => "3.0.3"
          :remote_base  => "http://maven.ign.com/nexus/content/repositories/releases/"
          :context      => "orinoco#v3"
          :enabled      => true
    }
    {
          :resolver         => :nexus
          :group_id         => "com.ign"
          :artifact_id      => "orinoco"
          :version          => "3.0.4-SNAPSHOT"
          :remote_base      => "http://maven.ign.com/nexus"
          :context          => "orinoco#snapshot"
          :enabled          => true
          :resolver_params  => { :repository_id => "snapshots"}
    }
    {
          :resolver         => :nexus
          :group_id         => "com.ign"
          :artifact_id      => "orinoco"
          :version          => "LATEST"
          :remote_base      => "http://maven.ign.com/nexus"
          :context          => "orinoco#latest"
          :enabled          => true
    }

]
```

Note 

### Resolvers

#### The Default Resolver (defaults)

It requires a specific directory and file layout, to explain I'll use an example where the group_id = "com.ign", artifact_id = "orinoco" and version = "3.0.3".
    * The directory layout should look like <remote_base>/com/ign/orinoco/3.0.3
    * The directory must contain a orinoco-3.0.3.war and two files that contain the MD5 and SHA1 of the file orinoco-3.0.3.war.md5 and orinoco-3.0.3.war.sha1
    * In this example the file orinoco-3.0.3.war.md5 just has the MD5 of orinoco.3.0.3.war i.e 2ec7199185d012c8c810e980d9f3680a
    * In this example the file orinoco-3.0.3.war.sha1 just has the SHA1 of orinoco.3.0.3.war i.e 7282db09c0899884d968f623d69c3ae3c0de2a5d

In a nutshell, if I would `ls <remote_base>/com/ign/orinoco/3.0.3` I get `orinoco-3.0.3.war orinoco-3.0.3.war.md5 orinoco-3.0.3.war.sha1`.

The remote_base can either be a empty and therefore point to a file in a cookbook or through http, as in the example above.


#### The Nexus Resolver (:nexus) 

It basically talks to a Sonatype Nexus server through their _Redirect_ API. If no :repository_id is set through the :resolver_params it will default to "snapshots" if the version ends with "SNAPSHOT" else it will use "releases".
In the example above "http://maven.ign.com/nexus" is the context where our Sonatype Nexus Server lives. i.e. to hit the landing page we go to http://maven.ign.com/nexus/index.html#welcome.

Usage
=====

An example of its usage will be.

##  Using Vagrant and deploying with defaults.

In the Vagrant file we have:

```ruby
#!/usr/bin/env ruby

Vagrant::Config.run do |config|

  # Web App Servers
  config.vm.define :app do |app_config|

    app_config.vm.box = "centos-6"
    app_config.vm.network :hostonly, "33.33.33.30"
    app_config.vm.share_folder("tomcat-gz-path", "/tmp/archive/tomcat", "archives/tomcat")

    config.vm.provision :chef_solo do |chef|

      chef.cookbooks_path = ["cookbooks", "ign-cookbooks"]
      chef.add_recipe 'ign-tomcat'

      chef.json.merge!(
          {
              :java   => {
                  :install_flavor => "sun",
                  :version        => "6u25"
              }
          }
      )
```

Now go to http://33.33.33.30:8080/demo


## Using Vagrant and customizing the recipe. Includes deploying applications hosted in remote locations.

In the Vagrant file we have:

```ruby
#!/usr/bin/env ruby

Vagrant::Config.run do |config|

  # Web App Servers
  config.vm.define :app do |app_config|

    app_config.vm.box = "centos-6"
    app_config.vm.network :hostonly, "33.33.33.30"
    app_config.vm.share_folder("tomcat-gz-path", "/tmp/archive/tomcat", "archives/tomcat")

    config.vm.provision :chef_solo do |chef|


      chef.cookbooks_path = ["cookbooks", "ign-cookbooks"]
      chef.roles_path = "roles"
      chef.data_bags_path = "data_bags"
      chef.add_recipe 'ign-tomcat'

      chef.json.merge!(
          {
              :java   => {
                  :install_flavor => "sun",
                  :version        => "6u25"
              },
              :tomcat => {
                  :java => {
                      :xopt     => {
                          :min_heap => "64m",
                          :max_heap => "128m"
                      },
                      :run_mode => "staging"
                  },
                  :users => {
                    :group => "tomcat",
                    :group_data_bag => "groups",
                    :users_data_bag => "tomcat-users"
                  }
              },
              :apps   => {
                  :profiles => [
                      {
                          :group_id     => "demo-group",
                          :artifact_id  => "demo-app",
                          :version      => "1.0",
                          :context      => "demo",
                          :enabled      => true
                      },
                      {
                          :group_id     => "com.ign",
                          :artifact_id  => "orinoco",
                          :version      => "3.0.3",
                          :remote_base  => "http://maven.ign.com/nexus/content/repositories/releases/",
                          :context      => "orinoco#v3",
                          :enabled      => true
                      },
                      {
                          :resolver         => :nexus,
                          :group_id         => "com.ign",
                          :artifact_id      => "orinoco",
                          :version          => "3.0.4-SNAPSHOT",
                          :remote_base      => "http://maven.ign.com/nexus",
                          :context          => "orinoco#snapshot",
                          :enabled          => true
                      },
                      {
                          :resolver         => :nexus,
                          :group_id         => "com.ign",
                          :artifact_id      => "orinoco",
                          :version          => "LATEST",
                          :remote_base      => "http://maven.ign.com/nexus",
                          :context          => "orinoco#latest",
                          :enabled          => true
                      }




                  ]
              }
          }
      )
```

Our User Group in `data_bags/groups/tomcat.json`

```json
{
	"id": "tomcat",
	"gid": 270
}
```

Our User in `data_bags/tomcat-users/tc-default.json`. *Note* that we are using the _default_ user id *tc-default*, you can change this with the `tomcat/users/user` attribute.

```json
{
  "id": "tc-default",
  "shell": "/bin/bash",
  "uid": 270,
  "directory": "/etc/tomcat",
  "comment": "Tomcat Default Instance User",
  "password": "$1$!@#$%@#$%@#$%@#$%@#$%@#$%...",
  "netgroups": ["tomcat"],
  "system": true,
  "groups": ["nossh"]
}
```