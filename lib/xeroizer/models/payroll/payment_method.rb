module Xeroizer
  module Record
    module Payroll

      class PaymentMethodModel < PayrollBaseModel

      end

      class PaymentMethod < PayrollBase

        PAYMENT_METHOD_TYPE = {
          'CHECK' => '',
          'MANUAL' => '',
          'DIRECTDEPOSIT' => ''
        } unless defined?(PAYMENT_METHOD_TYPE)

        string    :payment_method_type
        has_many  :bank_accounts

        validates_inclusion_of :payment_method_type, :in => PAYMENT_METHOD_TYPE
      end
    end
  end
end
