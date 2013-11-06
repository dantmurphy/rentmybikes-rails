class BalancedService
  def initialize()
    Balanced::Marketplace.my_marketplace
  end

  def debit(rental)
    owner_customer = rental.owner.balanced_customer
    renter_customer = rental.buyer.balanced_customer

    debit = renter_customer.debit(
      amount: rental.price,
      description: rental.listing.description,
      on_behalf_of: owner_customer
    )

    rental.debit_uri = debit.uri

    return debit
  end

  def credit(rental)
    owner_customer = rental.owner.balanced_customer

    credit = owner_customer.credit(
      amount: rental.price,
      description: rental.listing.description
    )

    rental.credit_uri = credit.uri

    return credit
  end
end
