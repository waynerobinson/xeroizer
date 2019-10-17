module Xeroizer
  module Record
    module Payroll

      class TimeOffTypeModel < PayrollBaseModel

        set_permissions :read

      end

      class TimeOffType < PayrollBase

        TIME_OFF_CATEGORIES = {
          'PAID' => '',
          'UNPAID' => ''
        } unless defined?(TIME_OFF_CATEGORIES)

        set_primary_key :time_off_type_id

        guid    :time_off_type_id
        string  :time_off_type
        string  :time_off_category
        string  :expense_account_code
        string  :liability_account_code
        boolean :show_balance_to_employee

        validates_inclusion_of :time_off_category, :in => TIME_OFF_CATEGORIES

      end
    end
  end
end