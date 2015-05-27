class LinkedAccount < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :posts

  serialize :auth_data, Hash

  before_save :set_name

  def account_type
    type
  end

  private #####################################################################

  def set_name
  end
end