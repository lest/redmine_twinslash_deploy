require_dependency 'projects_helper'

module ProjectsHelper
  def project_settings_tabs_with_twinslash_deploy
    tabs = project_settings_tabs_without_twinslash_deploy
    tabs << {:name => 'deploys',
             :controller => 'deploys',
             :action => :index,
             :partial => 'deploys/index',
             :label => :label_deploy_plural} if User.current.allowed_to?(:manage_deploys, @project)
    tabs
  end
  alias_method_chain :project_settings_tabs, :twinslash_deploy
end
