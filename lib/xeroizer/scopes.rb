module Xeroizer
  class Scopes
    def self.all_payroll
      ['employees', 'payitems', 'leaveapplications', 'payrollcalendars', 'payruns', 'payslip', 'superfunds', 'superfundproducts', 'timesheets'].map {|s| "payroll.#{s}"}.join(',')
    end
  end
end