class Rental < ActiveRecord::Base
  belongs_to :buyer, :class_name => 'User'
  belongs_to :owner, :class_name => 'User'
  belongs_to :listing

  attr_accessible :listing_Id, :owner_id, :buyer_id, :debit_uri, :credit_uri

  def price
    self.listing.price
  end

  def commission_rate
    0.1
  end

end
