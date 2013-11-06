class SubledgerService

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  def initialize()
    @subledger = MySubledger.new
  end

  def escrow_account
    @subledger.accounts.new_or_create(id: MySubledger.escrow_account)
  end

  def listing_full_url(listing) 
    listing_url(listing, host: "http://rentmybikes.subledger.com")
  end

  def debit(rental)
    listing    = rental.listing
    renter     = rental.buyer
    owner      = rental.owner
    escrow     = self.escrow_account

    price = BigDecimal.new(rental.price / 100, 2)
    commission = BigDecimal.new((rental.price / 100) * rental.commission_rate, 2)
    net_price = price - commission

    description =  truncate(listing.description, length: 20)

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  "Rented: #{description}",
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

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  "Payment Received: #{description}",
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: escrow,
          value: @subledger.debit(price)
        },
        {
          account: renter.ar_account,
          value: @subledger.credit(price)
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

    description =  truncate(listing.description, length: 20)

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  "Payout Complete: #{description}",
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: owner.ap_account,
          value: @subledger.debit(net_price)
        }, {
          account: escrow,
          value: @subledger.credit(net_price)
        }
      ]
    )
  end
end
