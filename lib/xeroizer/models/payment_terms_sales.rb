module Xeroizer
  module Record

    class PaymentTermsSalesModel < BaseModel
      set_xml_node_name 'Sales'
    end
    
    class PaymentTermsSales < Base

      PAYMENT_TERMS_SALES_TYPE = {
        'OFFOLLOWINGMONTH'    => '',
        'DAYSAFTERBILLDATE'   => '',
        'DAYSAFTERBILLMONTH'  => '',
        'OFCURRENTMONTH'      => ''
        } unless defined?(PAYMENT_TERMS_SALES_TYPE)
      
      string :day
      string :type

      validates_inclusion_of :type, :in => PAYMENT_TERMS_SALES_TYPE.keys, :allow_blanks => true
    end

  end
end
