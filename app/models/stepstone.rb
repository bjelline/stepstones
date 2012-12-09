class Stepstone < ActiveRecord::Base
  belongs_to :adventure
  has_many :steps
  attr_accessible :adventure_id, :description, :title

  validates :title, :length => { :minimum => 5 }

end
