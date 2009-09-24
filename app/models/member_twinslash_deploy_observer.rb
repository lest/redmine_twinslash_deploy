class MemberTwinslashDeployObserver < ActiveRecord::Observer
  observe :member

  def after_save(member)
    vhost_add_user_command = Setting.plugin_redmine_twinslash_deploy['vhost_add_user_command']
    project = member.project
    for deploy in project.deploys
      identifier = project.identifier + (deploy.suffix.empty? ? '' : '-' + deploy.suffix)
      system("#{vhost_add_user_command} #{identifier} #{member.user.login}") if vhost_add_user_command
    end
  end

  def after_destroy(member)
    vhost_del_user_command = Setting.plugin_redmine_twinslash_deploy['vhost_del_user_command']
    project = member.project
    for deploy in project.deploys
      identifier = project.identifier + (deploy.suffix.empty? ? '' : '-' + deploy.suffix)
      system("#{vhost_del_user_command} #{identifier} #{member.user.login}") if vhost_del_user_command
    end
  end
end
