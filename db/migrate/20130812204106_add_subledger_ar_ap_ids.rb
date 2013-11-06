class AddSubledgerArApIds < ActiveRecord::Migration
  def change
    add_column :users, :subledger_ar_acct_id, :string
    add_column :users, :subledger_ap_acct_id, :string
    add_column :users, :subledger_revenue_acct_id, :string
  end
end
