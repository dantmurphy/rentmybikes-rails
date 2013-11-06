namespace :subledger do
  desc "Subledger Utils"

  # rake subledger:create["example@test.com","Test Account","Test Org","Test Book"]
  task :create, [:email, :identity_desc, :org_desc, :book_desc] => :environment do |t, args|
    email         = args[:email]
    identity_desc = args[:identity_desc]
    org_desc      = args[:org_desc]
    book_desc     = args[:book_desc]
     
    # create blank subledger instance
    subledger = Subledger.new
     
    puts "* Creating identity:"
    puts "  Email: #{email}"
    puts "  Description: #{identity_desc}"
     
    identity, key = subledger.identities.create email:       email,
                                                description: identity_desc
     
    # recreate subledger instance using key and secret
    subledger = Subledger.new key_id: key.id,
                              secret: key.secret
     
    puts ""
    puts "* Creating Org:"
    puts "  key_id: #{key.id}"
    puts "  secret: #{key.secret}"
    puts "  description: #{org_desc}"
     
    org = subledger.orgs.create description: org_desc
     
    puts ""
    puts "* Creating Book"
    puts "  org_id: #{org.id}"
    puts "  description: #{book_desc}"
     
    book = subledger.books.create org:         org,
                                  description: book_desc

    puts ""
    puts "* You are all set"
    puts "* Just add/set the the following on .env and config/creds:"
    puts "SUBLEDGER_KEY_ID='#{key.id}'"
    puts "SUBLEDGER_SECRET='#{key.secret}'"
    puts "SUBLEDGER_ORG_ID='#{org.id}'"
    puts "SUBLEDGER_BOOK_ID='#{book.id}'"
  end

  task :book, [:book_desc] => :environment do |t, args|
    book_desc = args[:book_desc]

    # create my subledger instance
    my_subledger = MySubledger.new

    # get org id
    org = ENV['SUBLEDGER_ORG_ID']

    puts ""
    puts "* Creating Book"
    puts "  org_id: #{org}"
    puts "  description: #{book_desc}"

    book = my_subledger.books.create org:         my_subledger.org.read(id: org),
                                     description: book_desc

    puts ""
    puts "* Book created"
    puts "SUBLEDGER_BOOK_ID='#{book.id}'"
  end

  # run after running subledger:create, and making the setup it indicates
  # normal_balance: "d" or "c"
  #
  # rake subledger:escrow["Example Escrow","http://yoursite.com","0"]
  task :escrow, [:description, :reference, :normal_balance] => :environment do |t, args|
    description    = args[:description]
    reference      = args[:reference]
    normal_balance = args[:normal_balance]

    # create my subledger instance
    my_subledger = MySubledger.new

    puts "* Creating Escrow Account:"
    puts "  Description: #{description}"
    puts "  Reference: #{reference}"
    puts "  Normal Balance: #{normal_balance}"

    balance = nil
    if normal_balance == "d"
      balance = my_subledger.debit
    else
      balance = my_subledger.credit
    end

    escrow = my_subledger.account.create description:    description,
                                         reference:      reference,
                                         normal_balance: balance

    puts ""
    puts "* Escrow Account created"
    puts "* Just add/set the following to .env and config/creds:"
    puts "SUBLEDGER_ESCROW_ID='#{escrow.id}'"
  end

  task :report, [] => :environment do |t, args|
    # create my subledger instance
    subledger = MySubledger.new

    # create categories
    puts "* Creating Categories:"

    assets_category = subledger.categories.create :description => 'Assets', normal_balance: Subledger::Domain::Debit, version: 1
    puts "- Assets category created"

    liabilities_category = subledger.categories.create :description => 'Liabilities', normal_balance: Subledger::Domain::Credit, version: 1
    puts "- Liabilities category created"

    escrow_category = subledger.categories.create :description => 'Escrow', normal_balance: Subledger::Domain::Debit, version: 1
    puts "- Escrow category created"

    ar_category = subledger.categories.create :description => 'Accounts Receivable', normal_balance: Subledger::Domain::Debit, version: 1
    puts "- Accounts Receivable category created: #{ar_category.id}"

    ap_category = subledger.categories.create :description => 'Accounts Payable', normal_balance: Subledger::Domain::Credit, version: 1
    puts "- Accounts Payable category created: #{ap_category.id}"

    revenue_category = subledger.categories.create :description => 'Revenue', normal_balance: Subledger::Domain::Credit, version: 1
    puts "- Revenue category created: #{revenue_category.id}"

    # attach accounts to categories
    puts "* Attaching Accounts to Categories"

    escrow_category.attach :account => subledger.account(:id => MySubledger.escrow_account)
    puts "- Escrow account attached to escrow category"

    User.all.each do |user|
      if user.subledger_ap_acct_id.present?
        ap_category.attach :account => subledger.account(:id => user.subledger_ap_acct_id)
        puts "- User ap account attached to ap category"
      end

      if user.subledger_ar_acct_id.present?
        ar_category.attach :account => subledger.account(:id => user.subledger_ar_acct_id)
        puts "- user ar account attached to ar category"
      end

      if user.subledger_revenue_acct_id.present?
        revenue_category.attach :account => subledger.account(:id => user.subledger_revenue_acct_id)
        puts "- user revenue account attached to revenue category"
      end
    end

    # create the report
    puts "* Creating the report"
    balance_sheet = subledger.report.create(:description => 'Balance Sheet')

    # attach categories to report
    puts "* Attaching categories to report"

    balance_sheet.attach :category => assets_category
    puts "- Assets category attached to report"

    balance_sheet.attach :category => liabilities_category
    puts "- Liabilities category attached to report"

    balance_sheet.attach :category => escrow_category,
                         :parent   => assets_category
    puts "- Escrow category attached to report, with assets category as parent"

    balance_sheet.attach :category => ar_category,
                         :parent   => assets_category
    puts "- AR category attached to report, with assets category as parent"

    balance_sheet.attach :category => ap_category,
                         :parent   => liabilities_category
    puts "- AP category attached to report, with liabilities category as parent"

    balance_sheet.attach :category => revenue_category
    puts "- Revenue category attached to report"

    puts "* Just add/set the following to .env and config/creds:"
    puts "SUBLEDGER_AR_CATEGORY_ID='#{ar_category.id}'"
    puts "SUBLEDGER_AP_CATEGORY_ID='#{ap_category.id}'"
    puts "SUBLEDGER_REVENUE_CATEGORY_ID='#{revenue_category.id}'"
    puts "All done."
  end

  task :report_attach_users, [] => :environment do |t, args|
    # create my subledger instance
    subledger = MySubledger.new

    ap_category = subledger.categories.read :id => MySubledger.ap_category
    puts "AP Category is #{ap_category.id}"

    ar_category = subledger.categories.read :id => MySubledger.ar_category
    puts "AR Category is #{ar_category.id}"

    revenue_category = subledger.categories.read :id => MySubledger.revenue_category
    puts "Revenue Category is #{revenue_category.id}"

    User.all.each do |user|
      puts "- User: #{user.email}"

      if user.subledger_ap_acct_id.present?
        ap_category.attach :account => subledger.account(:id => user.subledger_ap_acct_id)
        puts "- User ap account attached to ap category"
      end

      if user.subledger_ar_acct_id.present?
        ar_category.attach :account => subledger.account(:id => user.subledger_ar_acct_id)
        puts "- user ar account attached to ar category"
      end

      if user.subledger_revenue_acct_id.present?
        revenue_category.attach :account => subledger.account(:id => user.subledger_revenue_acct_id)
        puts "- user revenue account attached to revenue category"
      end
    end
  end
end
