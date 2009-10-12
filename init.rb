require 'redmine'

require 'twinslash_deploy_project_patch'

Dispatcher.to_prepare do
  Project.send(:include, TwinslashDeployProjectPatch)
end

Redmine::Plugin.register :redmine_twinslash_deploy do
  name 'Twinslash Deploy plugin'
  author 'Just Lest'
  description ''
  version '0.1.0'

  permission :manage_deploys, {:deploys => [:index, :new, :edit, :destroy, :create]}

  settings :default => {'template_dir' => '',
                        'vhost_create_command' => '',
                        'vhost_delete_command' => '',
                        'vhost_add_user_command' => '',
                        'vhost_del_user_command' => '',
                        'hudson_base_url' => ''},
           :partial => 'settings/twinslash_deploy_settings'
  
end

ActiveRecord::Base.observers << :member_twinslash_deploy_observer
