module Xeroizer
  module Record

    class UkAddressModel < BaseModel

    end

    class UkAddress < Base
      string :address_line1, :internal_name => :line1
      string :address_line2, :internal_name => :line2
      string :city
      string :suburb
      string :post_code
      string :country_name
    end

  end
end
