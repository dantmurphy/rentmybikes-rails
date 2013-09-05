class SubledgerService

  include Rails.application.routes.url_helpers

  def initialize()
    @subledger = MySubledger.new
  end

  def escrow_account
    @subledger.accounts.new_or_create(id: MySubledger.escrow_account)
  end

  def listing_full_url(listing) 
    listing_url(listing, host: "http://localhost:5000")
  end

  def balanced_url(uri)
    "https://api.balancedpayments.com#{uri}"
  end

  def debit(rental)
    listing    = rental.listing
    renter     = rental.buyer
    owner      = rental.owner
    escrow     = self.escrow_account

    price = BigDecimal.new(rental.price / 100, 2)
    commission = BigDecimal.new((rental.price / 100) * rental.commission_rate, 2)
    net_price = price - commission

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  listing.description,
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: renter.ar_account,
          value: @subledger.debit(price)
        }, {
          account: renter.revenue_account,
          value: @subledger.credit(commission) 
        }, {
          account: owner.ap_account, 
          value: @subledger.credit(net_price)
        }
      ]
    )

    puts rental.inspect
    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  listing.description,
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: escrow,
          reference: self.balanced_url(rental.debit_uri),
          value: @subledger.debit(BigDecimal.new(rental.price / 100, 2))
        },
        {
          account: renter.ar_account,
          reference: self.balanced_url(rental.debit_uri),
          value: @subledger.credit(BigDecimal.new(rental.price / 100, 2))
        }
      ]
    )
  end

  def credit(rental)
    listing   = rental.listing
    owner     = rental.owner
    escrow    = self.escrow_account

    price = BigDecimal.new(rental.price / 100, 2)
    commission = BigDecimal.new((rental.price / 100) * rental.commission_rate, 2)
    net_price = price - commission

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  listing.description,
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: owner.ap_account,
          reference: self.balanced_url(rental.credit_uri),
          value: @subledger.debit(net_price)
        }, {
          account: escrow,
          reference: self.balanced_url(rental.credit_uri),
          value: @subledger.credit(net_price)
        }
      ]
    )
  end
end