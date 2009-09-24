require_dependency 'project'

module TwinslashDeployProjectPatch
  def self.included(base)
    base.class_eval do
      unloadable
      has_many :deploys
    end
  end
end
