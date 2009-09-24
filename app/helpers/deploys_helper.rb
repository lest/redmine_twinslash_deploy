module DeploysHelper
  def deploy_template_collection_for_select
    template_dir = Setting.plugin_redmine_twinslash_deploy['template_dir']
    collection = [[ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]]
    collection += Dir.glob("#{template_dir}/*").collect { |e| File.basename(e) }.collect { |e| [e, e] }.sort
  end
end
