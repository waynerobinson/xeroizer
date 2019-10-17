require 'rubygems'
require 'date'
require 'forwardable'
require 'active_support/inflector'
require "active_support/core_ext/array"
require "active_support/core_ext/big_decimal/conversions"
require 'oauth'
require 'oauth/signature/rsa/sha1'
require 'nokogiri'
require 'builder'
require 'time'
require 'bigdecimal'
require 'cgi'

$: << File.expand_path(File.dirname(__FILE__))

require 'class_level_inheritable_attributes'
require 'xeroizer/exceptions'
require 'xeroizer/oauth'
require 'xeroizer/scopes'
require 'xeroizer/http_encoding_helper'
require 'xeroizer/http'

require 'xeroizer/record/base_model'
require 'xeroizer/record/payroll_base_model'
require 'xeroizer/record/payroll_array_base_model'
require 'xeroizer/record/base'
require 'xeroizer/record/payroll_base'
require 'xeroizer/record/payroll_array_base'
require 'xeroizer/configuration'

# Include models
require 'xeroizer/models/batch_payment'
require 'xeroizer/models/from_bank_account'
require 'xeroizer/models/to_bank_account'
require 'xeroizer/models/bank_transfer'
require 'xeroizer/models/expense_claim'
require 'xeroizer/models/invoice_reminder'
require 'xeroizer/models/online_invoice'
require 'xeroizer/models/payment_service'
require 'xeroizer/models/prepayment'
require 'xeroizer/models/overpayment'
require 'xeroizer/models/purchase_order'
require 'xeroizer/models/receipt'
require 'xeroizer/models/repeating_invoice'
require 'xeroizer/models/schedule'
require 'xeroizer/models/tax_component'
require 'xeroizer/models/user'
require 'xeroizer/models/contact_sales_tracking_category'
require 'xeroizer/models/contact_purchases_tracking_category'

require 'xeroizer/models/payroll/benefit_line'
require 'xeroizer/models/payroll/benefit_type'
require 'xeroizer/models/payroll/earnings_type'
require 'xeroizer/models/payroll/address'
require 'xeroizer/models/payroll/payment_method'
require 'xeroizer/models/payroll/pay_schedule'
require 'xeroizer/models/payroll/paystub'
require 'xeroizer/models/payroll/salary_and_wage'
require 'xeroizer/models/payroll/tax_declaration'
require 'xeroizer/models/payroll/time_off_line'
require 'xeroizer/models/payroll/time_off_type'
require 'xeroizer/models/payroll/work_location'

# TODO Merge in above lists
['account','address','allocation','branding_theme','bank_transaction','bank_account','contact','contact_group',
  'credit_note','currency','employee','invoice','item','item_purchase_details','item_sales_details',
  'journal','journal_line','line_item','manual_journal','manual_journal_line','option','organisation',
  'payment','phone','tax_rate','tracking_category','tracking_category_child',
  'journal_line_tracking_category'].each do |model|
    require "xeroizer/models/#{model}"
end

# Include payroll models
['home_address', 'bank_account', 'employee', 'timesheet', 'timesheet_line', 'number_of_unit',
  'leave_application', 'leave_period', 'pay_items', 'deduction_type', 'earnings_rate',
  'reimbursement_type', 'leave_type', 'payroll_calendar', 'pay_template', 'super_membership',
  'leave_line', 'reimbursement_line', 'super_line', 'deduction_line', 'earnings_line', 'opening_balance',
  'pay_run', 'settings', 'tracking_categories', 'employee_groups', 'timesheet_categories', 'account'].each do |payroll_model|
    require "xeroizer/models/payroll/#{payroll_model}"
end

require 'xeroizer/report/factory'

require 'xeroizer/response'

require 'xeroizer/generic_application'
require 'xeroizer/public_application'
require 'xeroizer/private_application'
require 'xeroizer/partner_application'
require 'xeroizer/payroll_application'
