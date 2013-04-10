require 'xeroizer/record/application_helper'

module Xeroizer
  class GenericApplication
    
    include Http
    extend Record::ApplicationHelper
    
    attr_reader :client, :rate_limit_sleep, :rate_limit_max_attempts
    attr_accessor :logger, :xero_url
    
    extend Forwardable
    def_delegators :client, :access_token
    
    record :Account
    record :BrandingTheme
    record :Contact
    record :CreditNote
    record :Currency
    record :Employee
    record :Invoice
    record :Item
    record :Journal
    record :ManualJournal
    record :Organisation
    record :Payment
    record :TaxRate
    record :TrackingCategory
    record :BankTransaction

    report :AgedPayablesByContact
    report :AgedReceivablesByContact
    report :BalanceSheet
    report :BankStatement
    report :BankSummary
    report :BudgetSummary
    report :ExecutiveSummary
    report :ProfitAndLoss
    report :TrialBalance
    
    public
    
      # Never used directly. Use sub-classes instead.
      # @see PublicApplication
      # @see PrivateApplication
      # @see PartnerApplication
      def initialize(consumer_key, consumer_secret, options = {})
        @xero_url = options[:xero_url] || "https://api.xero.com/api.xro/2.0"
        @rate_limit_sleep = options[:rate_limit_sleep] || false
        @rate_limit_max_attempts = options[:rate_limit_max_attempts] || 5
        @client   = OAuth.new(consumer_key, consumer_secret, options)
      end

      def payroll(options = {})
        xero_client = self.clone
        xero_client.xero_url = options[:xero_url] || "https://api.xero.com/payroll.xro/1.0"
        @payroll ||= PayrollApplication.new(xero_client)
      end
          
  end
end
