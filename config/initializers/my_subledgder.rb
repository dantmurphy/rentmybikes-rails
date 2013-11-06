module MySubledger
  def self.new
    Subledger.new :key_id      => ENV['SUBLEDGER_KEY_ID'],
                  :identity_id => ENV['SUBLEDGER_IDENTITY_ID'],
                  :secret      => ENV['SUBLEDGER_SECRET'],
                  :org_id      => ENV['SUBLEDGER_ORG_ID'],
                  :book_id     => ENV['SUBLEDGER_BOOK_ID']
  end

  def self.escrow_account
    ENV['SUBLEDGER_ESCROW_ID']
  end

  def self.ar_category
    ENV['SUBLEDGER_AR_CATEGORY_ID']
  end

  def self.ap_category
    ENV['SUBLEDGER_AP_CATEGORY_ID']
  end

  def self.revenue_category
    ENV['SUBLEDGER_REVENUE_CATEGORY_ID']
  end
end
