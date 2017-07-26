require 'xeroizer/record/application_helper'

module Xeroizer
  class GenericApplication

    include Http
    extend Record::ApplicationHelper

    attr_writer :xero_url_prefix, :xero_url_suffix, :api_format
    attr_reader :client, :xero_url, :logger, :rate_limit_sleep, :rate_limit_max_attempts,
                :default_headers, :unitdp, :before_request, :after_request, :nonce_used_max_attempts,
                :api_format

    extend Forwardable
    def_delegators :client, :access_token

    record :Account
    record :Allocation
    record :Attachment
    record :BrandingTheme
    record :Contact
    record :ContactGroup
    record :CreditNote
    record :Currency
    record :Employee
    record :ExpenseClaim
    record :Invoice
    record :Item
    record :Journal
    record :ManualJournal
    record :Organisation
    record :User
    record :Payment
    record :Prepayment
    record :PurchaseOrder
    record :Receipt
    record :RepeatingInvoice
    record :Schedule
    record :TaxRate
    record :TrackingCategory
    record :TrackingCategoryChild
    record :BankTransaction
    record :User

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
        @api_format = options[:api_format] || :xml
        @xero_url_prefix = options[:xero_url_prefix] || "https://api.xero.com"
        @xero_url_suffix = options[:xero_url_suffix] || "api.xro/2.0"
        @rate_limit_sleep = options[:rate_limit_sleep] || false
        @rate_limit_max_attempts = options[:rate_limit_max_attempts] || 5
        @nonce_used_max_attempts = options[:nonce_used_max_attempts] || 1
        @default_headers = options[:default_headers] || {}
        @before_request = options.delete(:before_request)
        @after_request = options.delete(:after_request)
        @client = OAuth.new(consumer_key, consumer_secret, options.merge({default_headers: default_headers}))
        @logger = options[:logger] || false
        @unitdp = options[:unitdp] || 2
      end

      def payroll(options = {})
        xero_client = self.clone
        xero_client.xero_url_suffix = options[:xero_url_suffix] || "payroll.xro/1.0"
        xero_client.api_format = options[:api_format] || :xml
        @payroll ||= PayrollApplication.new(xero_client)
      end

      def xero_url
        @xero_url_prefix + '/' + @xero_url_suffix
      end
  end
end
