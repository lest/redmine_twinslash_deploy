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
end
