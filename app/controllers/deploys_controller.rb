class DeploysController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def new
    @deploy = @project.deploys.build(params[:deploy])
  	if request.post? and @deploy.save
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
