module Xeroizer
  module Record
    line_amount_type = {
      "Inclusive" => 'Line item amounts are inclusive of tax',
      "Exclusive" => 'Line item amounts are exclusive of tax (default)',
      "NoTax"     => 'Line item amounts have no tax'
    }

    LINE_AMOUNT_TYPES = line_amount_type.keys.sort
  end
end
