class DeploysController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def new
    @deploy = @project.deploys.build(params[:deploy])
  	if request.post? and @deploy.save
      identifier = @project.identifier + (@deploy.suffix.empty? ? '' : '-' + @deploy.suffix)

      if @deploy.is_local?
        vhost_create_command = Setting.plugin_redmine_twinslash_deploy['vhost_create_command']
        vhost_add_user_command = Setting.plugin_redmine_twinslash_deploy['vhost_add_user_command']
        system("#{vhost_create_command} '#{@deploy.template}' #{identifier}") if vhost_create_command
        for user in @project.users
          system("#{vhost_add_user_command} #{identifier} #{user.login}") if vhost_add_user_command
        end
      end

      repository = @project.repository
      if repository.is_a?(Repository::Subversion) && !@deploy.svn_path.empty?
        hudson_create_command = Setting.plugin_redmine_twinslash_deploy['hudson_create_command']
        svn_path = repository.url + @deploy.svn_path
        system("#{hudson_create_command} '#{@deploy.template}' #{identifier} '#{svn_path}' '#{@deploy.name}'") if hudson_create_command
      end

  	  flash[:notice] = l(:notice_successful_create)
      redirect_to :controller => 'projects', :action => 'settings', :tab => 'deploys', :id => @project
  	end
  end

  def edit
    if request.post? and @deploy.update_attributes(params[:deploy])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'projects', :action => 'settings', :tab => 'deploys', :id => @project
    end
  end

  def destroy
    identifier = @project.identifier + (@deploy.suffix.empty? ? '' : '-' + @deploy.suffix)

    if @deploy.is_local?
      vhost_delete_command = Setting.plugin_redmine_twinslash_deploy['vhost_delete_command']
      system("#{vhost_delete_command} #{identifier}") if vhost_delete_command
    end

    repository = @project.repository
    if repository.is_a?(Repository::Subversion) && !@deploy.svn_path.empty?
      hudson_delete_command = Setting.plugin_redmine_twinslash_deploy['hudson_delete_command']
      system("#{hudson_delete_command} #{identifier}") if hudson_delete_command
    end

    @deploy.destroy
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'deploys', :id => @project
  rescue
    flash[:error] = l(:notice_unable_delete_deploy)
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'deploys', :id => @project
  end

  private
    def find_project
      if params[:action] != 'new'
        @deploy = Deploy.find(params[:id])
        @project = @deploy.project
      else
        @project = Project.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      render_404
    end
end
