class RentalsController < ApplicationController

  def create
    # retrieve the listing
    listing = Listing.find(params[:listing_id])

    # logic to handle guest/not signed in users
    if user_signed_in?
      renter = current_user

    else
      renter = User.new(
        name: params[:"guest-name"],
        email: params[:"guest-email_address"]
      )
    end

    # get card information
    card = params[:card_uri]

    # rent the listing
    listing.rent(renter, card)

    render :confirmation
  end

end
