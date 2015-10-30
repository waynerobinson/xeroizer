module Xeroizer
  module Record
    module Payroll

      class PaystubModel < PayrollBaseModel

        set_permissions :read, :write, :update

        public

          # Retrieve the PDF version of the paystub matching the `id`.
          # @param [String] id paystub's ID.
          # @param [String] filename optional filename to store the PDF in instead of returning the data.
          def pdf(id, filename = nil)
            pdf_data = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", :response => :pdf)
            if filename
              File.open(filename, "w") { | fp | fp.write pdf_data }
              nil
            else
              pdf_data
            end
          end

      end

      class Paystub < PayrollBase

        set_primary_key :paystub_id

        guid          :paystub_id
        guid          :employee_id
        guid          :pay_run_id
        string        :first_name
        string        :last_name
        datetime      :last_edited
        decimal       :earnings
        decimal       :deductions
        decimal       :tax
        decimal       :reimbursements
        decimal       :net_pay
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        has_many      :earnings_lines
        has_many      :leave_earnings_lines, :model_name => 'EarningsLine'
        has_many      :timesheet_earnings_lines, :model_name => 'EarningsLine'
        has_many      :deduction_lines
        has_many      :reimbursement_lines
        has_many      :benefit_lines
        has_many      :time_off_lines

        validates_presence_of :paystub_id, :unless => :new_record?

        public

          # Retrieve the PDF version of this paystub.
          # @param [String] filename optional filename to store the PDF in instead of returning the data.
          def pdf(filename = nil)
            parent.pdf(id, filename)
          end
      end
    end
  end
end
