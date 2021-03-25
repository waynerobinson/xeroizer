module Xeroizer
  class Scopes
    def self.all_payroll
      (['Employees', 'PayRuns', 'Payslip', 'Settings', 'Timesheets'].map {|s| "payroll.#{s.downcase}"} +
       ['Settings'].map {|s| "accounting.#{s.downcase}"} +
       ['offline_access']
      ).join(' ') 
    end

    def self.au_payroll
      all_payroll
    end

    def self.us_payroll
      (
       ['Employees', 'PayItems', 'PaySchedules', 'PayRuns', 'Paystubs', 'Worklocations', 'Settings', 'Timesheets'].map {|s| "payroll.#{s.downcase}"} +
       ['Settings'].map {|s| "accounting.#{s.downcase}"} +
       ['offline_access']
      ).join(' ')
    end
  end
end