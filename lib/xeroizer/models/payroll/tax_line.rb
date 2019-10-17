module Xeroizer
  module Record
    module Payroll
    
      class TaxLineModel < PayrollBaseModel
          
      end
      
      # http://developer.xero.com/documentation/payroll-api/payslip/#TaxLine
      class TaxLine < PayrollBase

        string        :tax_type_name
        string        :description
        string        :liability_account

        decimal       :amount

        guid          :payslilp_tax_line_id

      end

    end 
  end
end
