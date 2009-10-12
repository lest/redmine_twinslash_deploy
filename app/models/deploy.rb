class Deploy < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  
  validates_presence_of :name
  validates_format_of :name, :with => /^[a-z0-9]*$/i
  validates_length_of :name, :maximum => 60
  validates_uniqueness_of :name, :scope => [:project_id]

  validates_format_of :suffix, :with => /^[a-z0-9]*$/i
  validates_length_of :suffix, :maximum => 10
  validates_uniqueness_of :suffix, :scope => [:project_id]

  validates_presence_of :template

  def is_local?
    !is_remote?
  end

  def identifier
    project.identifier + (suffix.empty? ? '' : '-' + suffix)
  end

  def full_svn_path
    project.repository.url + svn_path
  end

  def after_save
    if is_local?
      vhost_create_command = Setting.plugin_redmine_twinslash_deploy['vhost_create_command']
      vhost_add_user_command = Setting.plugin_redmine_twinslash_deploy['vhost_add_user_command']
      system("#{vhost_create_command} '#{template}' #{identifier}") if vhost_create_command && !vhost_create_command.empty?
      for user in project.users
        system("#{vhost_add_user_command} #{identifier} #{user.login}") if vhost_add_user_command && !vhost_add_user_command.empty?
      end
    end
    if project.repository.is_a?(Repository::Subversion) && !svn_path.empty?
      DeployHudsonApi.new.create_job(template, identifier, full_svn_path, name, project.users.collect { |u| u.login })
    end
  end

  def before_destroy
    if is_local?
      vhost_delete_command = Setting.plugin_redmine_twinslash_deploy['vhost_delete_command']
      system("#{vhost_delete_command} #{identifier}") if vhost_delete_command
    end
    if project.repository.is_a?(Repository::Subversion) && !svn_path.empty?
      DeployHudsonApi.new.delete_job(identifier)
    end
  end
end
