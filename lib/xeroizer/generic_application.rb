require 'xeroizer/record/application_helper'

module Xeroizer
  class GenericApplication
    
    include Http
    extend Record::ApplicationHelper
    
    attr_reader :client, :xero_url, :logger, :rate_limit_sleep, :rate_limit_max_attempts
    
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

      # Shortcut for instantiating any application type when in a Rails environment,
      # by putting authentication info in a yaml file.
      #
      # yaml file should be located at config/xeroizer.yml (recommended to put this in .gitignore) and should look like this:
      ################
      # test:
      #   my_xero_app:  # Pick any name you'd like
      #     consumer_key: ...
      #     consumer_secret: ...
      #     private_key_path: ... # For Private and Partner applications only.  Use absolute path
      #                           # Defaults to <Rails.root>/config/my_xero_app.pem in this
      #                           # example, since the application is called my_xero_app.
      #     ssl_client_cert_path: ... # For Partner applications only.  Use absolute path.
      #     ssl_client_cert_path: ... # For Partner applications only.  Use absolute path.
      # development:
      #   ...
      # production
      #   ...
      ################
      #
      # Now instantiate as follows:
      #
      # Xeroizer::PublicApplication.initialize_from_yaml(:my_xero_app)
      # Xeroizer::PrivateApplication.initialize_from_yaml(:my_xero_app)
      # Xeroizer::PartnerApplication.initialize_from_yaml(:my_xero_app)
      #
      # The options hash will be passed on, unaltered, to the constructor:
      # Xeroizer::PublicApplication.initialize_from_yaml(:my_xero_app, options_hash)
      #
      # @param	name	The name used in the YAML file to identify the application
      # @param	options	The options hash to pass to the constructor
      # @return 	A Xeroizer client of the same application type that the class method is
      #			called on (i.e. PublicApplication, PartnerApplication or PrivateApplication)
      if defined?(Rails)
        def self.initialize_from_yaml(name, options = {})
          oauth_params = YAML.load_file("#{::Rails.root}/config/xeroizer.yml")[Rails.env][name.to_s]
          consumer_key = oauth_params['consumer_key']
          consumer_secret = oauth_params['consumer_secret']
          if self.to_s == "Xeroizer::PrivateApplication"
            path_to_private_key = oauth_params['private_key_path'] || "#{::Rails.root}/config/#{name}.pem"
            self.new(consumer_key, consumer_secret, path_to_private_key, options)
          elsif self.to_s == "Xeroizer::PublicApplication"
            self.new(consumer_key, consumer_secret, options)
          elsif self.to_s == "Xeroizer::PartnerApplication"
            path_to_private_key = oauth_params['private_key_path'] || "#{::Rails.root}/config/#{name}.pem"
            path_to_ssl_client_cert = oauth_params['ssl_client_cert_path']
            path_to_ssl_client_key = oauth_params['ssl_client_key_path']
            self.new(consumer_key, consumer_secret, path_to_private_key, path_to_ssl_client_cert, path_to_ssl_client_key, options = {})
          end
        end
      end
  end
end
