module Xeroizer
  class Scopes
    def self.all_payroll
      (['Employees', 'PayRuns', 'Payslip', 'Settings', 'Timesheets'].map {|s| "payroll.#{s.downcase}"} + 'offline_acess').join(' ') 
    end

    def self.au_payroll
      all_payroll
    end

    def self.us_payroll
      (['Employees', 'PayItems', 'PaySchedules', 'PayRuns', 'Paystubs', 'Worklocations', 'Settings', 'Timesheets'].map {|s| "payroll.#{s.downcase}"} + 'offline_acess').join(' ')
    end
  end
end