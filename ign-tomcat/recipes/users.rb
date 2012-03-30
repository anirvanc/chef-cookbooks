
#Todo: move to an internal tomcat_user recipe
tomcat_group_db_name = node[:tomcat][:users][:group_data_bag]
tomcat_group         = node[:tomcat][:users][:group]

tomcat_users_db_name = node[:tomcat][:users][:user_data_bag]
tomcat_user          = node[:tomcat][:users][:user]


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



log("tomcat_users_db_name.nil? #{tomcat_users_db_name.nil?}")

if tomcat_users_db_name.nil?
  user(tomcat_user) do
    gid group
    shell "/bin/bash"
  end

  node[:tomcat][:user] = tomcat_user
else
  log "Expecting user #{tomcat_user} to be defined in Data_Bag #{tomcat_users_db_name}"
  # Load the keys of the items in the 'admins' data bag
  tomcat_user_details = data_bag_item("#{tomcat_users_db_name}", "#{tomcat_user}")
  #tomcat_user_details = data_bag_item('tomcat-users', 'tomcat-app')

  raise "Unable to find databa #{tomcat_users_db_name} for user #{tomcat_user}" if tomcat_user_details.nil?
  tomcat_user = tomcat_user_details['id']

  user(tomcat_user) do
    uid tomcat_user_details['uid']
    gid tomcat_user_details['gid']
    shell tomcat_user_details['shell']
    comment tomcat_user_details['comment']
    home tomcat_user_details['home']
    supports :manage_home => true
  end
  node[:tomcat][:user] = tomcat_user
end