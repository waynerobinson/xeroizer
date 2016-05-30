module Xeroizer
  module Record

    class PaymentTermsBillsModel < BaseModel
      set_xml_node_name 'Bills'
    end
    
    class PaymentTermsBills < Base

      PAYMENT_TERMS_BILLS_TYPE = {
        'OFFOLLOWINGMONTH'    => '',
        'DAYSAFTERBILLDATE'   => '',
        'DAYSAFTERBILLMONTH'  => '',
        'OFCURRENTMONTH'      => ''
        } unless defined?(PAYMENT_TERMS_BILLS_TYPE)
      
      string :day
      string :type

      validates_inclusion_of :type, :in => PAYMENT_TERMS_BILLS_TYPE.keys, :allow_blanks => true
    end

  end
end