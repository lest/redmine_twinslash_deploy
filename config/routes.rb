ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:id/deploys/new', :controller => 'deploys', :action => 'new'
end
