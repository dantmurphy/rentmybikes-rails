module SubledgerHelper
  def format_amount(account, value)
    if value.value.class == Subledger::Domain::Zero
      "#{number_to_currency value.amount}".html_safe

    elsif value.value.class == Subledger::Domain::Credit
      "<i class='icon-arrow-up'></i> #{number_to_currency value.amount}".html_safe

    else
      "<i class='icon-arrow-down'></i> #{number_to_currency value.amount}".html_safe
    end
  end
end
