class MoneyService
  def initialize()
  end

  def rent(listing, renter, card)
    # get listing owner
    owner = listing.user

    # add card to renter
    renter.add_card(card)

    # create a new rental
    rental = Rental.new
    rental.listing = listing
    rental.buyer   = renter
    rental.owner   = owner

    # charge renter for rental
    charge_renter(rental)

    # pay owner for rental
    # XXX temporarely disabled
    #pay_owner(rental) 

    # save the rental
    rental.save!

    return rental
  end

  # encapsulates charing renter logic
  def charge_renter(rental)
    # make debit operation on balanced
    balanced.debit(rental)

    # account it on subledger
    subledger.debit(rental)
  end

  # encapsulates paying owner logic
  def pay_owner(rental)
    # make credit operation on balanced
    balanced.credit(rental)

    # account it on subledger
    subledger.credit(rental)
  end

private
  def balanced
    @balanced ||= BalancedService.new
  end

  def subledger
    @subledger ||= SubledgerService.new
  end
end
