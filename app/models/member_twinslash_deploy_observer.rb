class MemberTwinslashDeployObserver < ActiveRecord::Observer
  unloadable

  observe :member

  def after_save(member)
    vhost_add_user_command = Setting.plugin_redmine_twinslash_deploy['vhost_add_user_command']
    project = member.project
    for deploy in project.deploys
      system("#{vhost_add_user_command} #{deploy.identifier} #{member.user.login}") if deploy.is_local? && vhost_add_user_command && !vhost_add_user_command.empty?
      if deploy.project.repository.is_a?(Repository::Subversion) && !deploy.svn_path.empty?
        DeployHudsonApi.new.add_user_to_job(deploy.identifier, member.user.login)
      end
    end
  end

  def after_destroy(member)
    vhost_del_user_command = Setting.plugin_redmine_twinslash_deploy['vhost_del_user_command']
    project = member.project
    for deploy in project.deploys
      system("#{vhost_del_user_command} #{identifier} #{member.user.login}") if deploy.is_local? && vhost_del_user_command && !vhost_del_user_command.empty?
      if deploy.project.repository.is_a?(Repository::Subversion) && !deploy.svn_path.empty?
        DeployHudsonApi.new.remove_user_from_job(deploy.identifier, member.user.login)
      end
    end
  end
end
