class Dmail < ActiveRecord::Base
  validates_presence_of :to_id
  validates_presence_of :from_id
  validates_format_of :title, :with => /\S/
  validates_format_of :body, :with => /\S/
  belongs_to :owner, :class_name => "User"
  belongs_to :to, :class_name => "User"
  belongs_to :from, :class_name => "User"
  after_create :update_recipient
  after_create :send_dmail
  attr_accessible :title, :body, :is_deleted
  scope :for, lambda {|user| where(["owner_id = ?", user])}
  scope :inbox, where("to_id = owner_id")
  scope :sent, where("from_id = owner_id")
  scope :active, where(["is_deleted = ?", false])
  scope :deleted, where(["is_deleted = ?", true])
  scope :search_message, lambda {|query| where(["message_index @@ plainto_tsquery(?)", query])}
  
  module AddressMethods
    def to_name
      User.find_pretty_name(to_id)
    end

    def from_name
      User.find_pretty_name(from_id)
    end

    def to_name=(name)
      user = User.find_by_name(name)
      return if user.nil?
      self.to_id = user.id
    end

    def from_name=(name)
      user = User.find_by_name(name)
      return if user.nil?
      self.from_id = user.id
    end
  end
  
  module FactoryMethods
    module ClassMethods
      def create_new(dmail)
        copy = dmail.clone
        copy.owner_id = dmail.to_id
        copy.save

        copy = dmail.clone
        copy.owner_id = dmail.from_id
        copy.save
      end
    end
    
    def self.included(m)
      m.extend(ClassMethods)
    end
    
    def build_response
      Dmail.new do |dmail|
        dmail.title = "Re: #{title}"
        dmail.owner_id = from_id
        dmail.body = quoted_body
        dmail.to_id = from_id
        dmail.from_id = to_id
        dmail.parent_id = id
      end
    end    
  end
  
  include AddressMethods
  include FactoryMethods
  
  def quoted_body
    "[quote]#{body}[/quote]"
  end
  
  def send_dmail
    if to.receive_email_notifications? && to.email.include?("@")
      UserMailer.dmail_notice(self).deliver
    end    
  end
  
  def mark_as_read!
    update_attribute(:is_read, true)
    
    unless Dmail.exists?(["to_id = ? AND is_read = false", to_id])
      to.update_attribute(:has_mail, false)
    end
  end
  
  def update_recipient
    to.update_attribute(:has_mail, true)
  end
end