  require 'openssl'

pw = String.new

while pw.length < 20
  pw << OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
end


default[:tomcat][:version]     = "7.0.25"
default[:tomcat][:with_native] = false
default[:tomcat][:java_home]   = "/usr/java/default"


set[:tomcat][:local]        = "/opt/tomcat"
set[:tomcat][:archive]      = "#{tomcat[:local]}/archive"
set[:tomcat][:home]         = "#{tomcat[:local]}/current"

# Holds the binary, zipped/gzip, distribution of Tomcat versions.
default[:tomcat][:distro]   = "/tmp/archive/tomcat"

# Used to name the given Tomcat Instance

default[:tomcat][:instance] = "default" #Todo: move to a global attribute file

#Todo: move to a tomcat_user attribute file
default[:tomcat][:users] = {
    :group => "tomcat",
    :user =>  "tc-#{node[:tomcat][:instance]}",
    :group_data_bag => nil,
    :users_data_bag => nil,
    :manage => true
}
#--


#-----------------------------------------------------------------------------------------------------------------------
#Todo: move to a tomcat_dist attribute file
set[:tomcat][:service]                       = "tomcat-#{tomcat[:instance]}"
set[:tomcat][:script]                        = "/etc/init.d/#{tomcat[:service]}"
set[:tomcat][:launcher]                      = "/etc/init.d/#{tomcat[:service]}d"
set[:tomcat][:start]                         = "#{tomcat[:script]} start"
set[:tomcat][:start]                         = "#{tomcat[:script]} start"
set[:tomcat][:stop]                          = "#{tomcat[:script]} stop"
set[:tomcat][:restart]                       = "#{tomcat[:script]} restart"


default[:tomcat][:logs_path] = "/var/log/tomcat"
default[:tomcat][:temp_path] = "/var/tmp/tomcat"
default[:tomcat][:base_path] = "/etc/tomcat"

set[:tomcat][:base]                 = "#{tomcat[:base_path]}/#{tomcat[:instance]}"
set[:tomcat][:conf]                 = "#{tomcat[:base]}/conf"
set[:tomcat][:webapps]              = "#{tomcat[:base]}/webapps"
set[:tomcat][:logs]                 = "#{tomcat[:logs_path]}/#{tomcat[:instance]}"
set[:tomcat][:out]                  = "#{tomcat[:logs]}/catalina.out"
set[:tomcat][:temp]                 = "#{tomcat[:temp_path]}/#{tomcat[:instance]}"

#set[:tomcat][:war_archive] = "/srv/tomcat/archive/#{tomcat[:instance]}"

default[:tomcat][:ajp_port]         = 8009
default[:tomcat][:http_port]        = 8080
default[:tomcat][:redirect_port]    = 8443
default[:tomcat][:shutdown_port]    = 8005
default[:tomcat][:snmp_port]        = 1161
default[:tomcat][:snmp_interface]   = "0.0.0.0"
default[:tomcat][:shutdown_wait]    = 3
default[:tomcat][:security_manager] = false
default[:tomcat][:shutdown_verbose] = false

#-----------------------------------------------------------------------------------------------------------------------
default[:tomcat][:jvm_route]        = "jvm-#{tomcat[:instance]}"

#for now will disable snmp
default[:tomcat][:with_snmp]        = false

if languages[:java]
  set[:tomcat][:with_snmp] = !languages[:java][:runtime][:name].match(/^OpenJDK/)
else
  set[:tomcat][:with_snmp] = false
end

# snmp_opts fail with OpenJDK - results in silent exit(1) from the jre
if tomcat[:with_snmp]
  set[:tomcat][:snmp_opts] = "-Dcom.sun.management.snmp.interface=#{tomcat[:snmp_interface]} -Dcom.sun.management.snmp.acl=false -Dcom.sun.management.snmp.port=#{tomcat[:snmp_port]}"
else
  set[:tomcat][:snmp_opts] = ""
end


# Review: http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html
#         http://www.ibm.com/developerworks/library/i-gctroub/ for details on JVM tuning.
# Xmin & Xmax:  -Xminf (minf is the minimum free). It gets shrunk if the ratio of free heap to total heap exceeds the value specified by -Xmaxf (maxf is the maximum free).
# Xmine & Xmax: -Xmine (mine is the minimum expansion size) and -Xmaxe (maxe is the maximum expansion size)
default[:tomcat][:java][:xopt]     = {
    :min_factor => 0.5,
    :max_factor => 0.9,
    :min_heap   => "64m",
    :max_heap   => "512m",
    :max_perm   => "96m"
}

# Configures the JVM Locale variables
default[:tomcat][:java][:locale]   = {
    :user_lang    => "en",
    :user_country => "US"
}

# Specifies the -Drun.mode for the JVM, valid values are Production, Staging, Test, Development
default[:tomcat][:java][:run_mode] = "production"

# Used to pass a set of Java Agents
#-javaagent:/var/opt/tomcat/sites-admin-01/newrelic/newrelic.jar
default[:tomcat][:java_agent]      = ""

#Used to provide additional Catalina Options
default[:tomcat][:catalina_opts]   = ""

#-XX:OnError="<cmd args>;<cmd args>"
#-XX:OnOutOfMemoryError="<cmd args>;<cmd args>"
default[:tomcat][:java_opts]           = <<EOF
#{tomcat[:java_agent]}
  -Xms#{tomcat[:java][:xopt][:min_heap]} -Xmx#{tomcat[:java][:xopt][:max_heap]} -XX:MaxPermSize=#{tomcat[:java][:xopt][:max_perm]}
  -Xminf#{tomcat[:java][:xopt][:min_factor]} -Xmaxf#{tomcat[:java][:xopt][:max_factor]}
  -XX:-UseParallelGC -XX:+AggressiveOpts -XX:+UseStringCache -XX:+UseCompressedStrings -XX:+OptimizeStringConcat
  -XX:ErrorFile=#{tomcat[:temp]}/hs_err_pid.log -XX:HeapDumpPath=#{tomcat[:temp]}/java_pid.hprof
  -XX:-HeapDumpOnOutOfMemoryError -XX:+AlwaysPreTouch
    -Duser.language=#{tomcat[:java][:locale][:user_lang]} -Duser.country=#{tomcat[:java][:locale][:user_country]}
  -Drun.mode=#{tomcat[:java][:run_mode]}
EOF

set[:tomcat][:java_instance_opts]     = "-Dtomcat.instance=#{tomcat[:instance]} -Dtomcat.jvmRoute=#{tomcat[:jvm_route]}"
set[:tomcat][:manager_user]           = "manager"
set[:tomcat][:manager_password]       = pw
set[:tomcat][:permgen_min_free_in_mb] = 24

default[:apps][:profiles] = [
    {
        :artifact_id    => "demo-app",
        :group_id       => "demo-group",
        :version        => "1.0",
        :context        => "demo",
        :enabled        => true
    }
]

set[:apps][:artifact_archive] = "/srv/tomcat/archive"
set[:apps][:staged_archive]   = "/srv/tomcat/staged"
