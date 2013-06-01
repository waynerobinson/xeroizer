module Xeroizer
  class Scopes
    def self.all_payroll
      ['Employees', 'LeaveApplications', 'PayItems', 'PayrollCalendars', 'PayRuns', 'Payslip', 'SuperFunds', 'SuperFundProducts', 'Timesheets'].map {|s| "payroll.#{s.downcase}"}.join(',')
    end
  end
end