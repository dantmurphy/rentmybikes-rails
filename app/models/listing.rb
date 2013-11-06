class Listing < ActiveRecord::Base
  belongs_to :user
  has_many :rentals

  attr_accessible :name, :user_id, :location, :title, :description, :bicycle_type
  attr_accessible :price, :owner_uri


  def rent(renter, card)
    rental = money.rent(self, renter, card)
    rental.save
  end

private
  def url_for balanced_line
    "https://dashboard.balancedpayments.com/#" + balanced_line.uri[3..-1]
  end

  def money
    @money ||= MoneyService.new
  end

end
