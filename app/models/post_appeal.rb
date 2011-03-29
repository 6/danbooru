class PostAppeal < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :creator, :class_name => "User"
  belongs_to :post
  validates_presence_of :reason, :creator_id, :creator_ip_addr
  validate :validate_post_is_inactive
  validate :validate_creator_is_not_limited
  before_validation :initialize_creator, :on => :create
  validates_uniqueness_of :creator_id, :scope => :post_id
  scope :for_user, lambda {|user_id| where(["creator_id = ?", user_id])}
  scope :recent, lambda {where(["created_at >= ?", 1.day.ago])}
  
  def validate_creator_is_not_limited
    if PostAppeal.for_user(creator_id).recent.count >= 5
      errors[:creator] << "can appeal 5 posts a day"
      false
    else
      true
    end
  end
  
  def validate_post_is_inactive
    if !post.is_deleted? && !post.is_flagged?
      errors[:post] << "is inactive"
      false
    else
      true
    end
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
    self.creator_ip_addr = CurrentUser.ip_addr
  end
end