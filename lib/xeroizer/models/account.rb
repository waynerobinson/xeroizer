module Xeroizer
  module Record

    class AccountModel < BaseModel

      set_permissions :read, :write, :update

      # The Accounts endpoint only supports PUT method for creation
      # Accounts must created one at a time
      def create_method
        :http_put
      end

      # Accounts can be updated using a POST request, only one account can be updated per request

    end

    class Account < Base

      ACCOUNT_STATUS = {
        'ACTIVE' => 'Active',
        'DELETED' => 'Deleted',
        'ARCHIVED' => 'Archived'
      } unless defined?(ACCOUNT_STATUS)
      ACCOUNT_STATUSES = ACCOUNT_STATUS.keys.sort

      TYPE = {
        'CURRENT' =>        '',
        'FIXED' =>          '',
        'PREPAYMENT' =>     '',
        'EQUITY' =>         '',
        'DEPRECIATN' =>     '',
        'DIRECTCOSTS' =>    '',
        'EXPENSE' =>        '',
        'OVERHEADS' =>      '',
        'CURRLIAB' =>       '',
        'LIABILITY' =>      '',
        'TERMLIAB' =>       '',
        'OTHERINCOME' =>    '',
        'REVENUE' =>        '',
        'SALES' =>          ''
      } unless defined?(TYPE)

      TAX_TYPE = {
        'NONE' =>             'No GST',
        'EXEMPTINPUT' =>      'VAT on expenses exempt from VAT (UK only)',
        'INPUT' =>            'GST on expenses',
        'SRINPUT' =>          'VAT on expenses',
        'ZERORATEDINPUT' =>   'Expense purchased from overseas (UK only)',
        'RRINPUT' =>          'Reduced rate VAT on expenses (UK Only)',
        'EXEMPTOUTPUT' =>     'VAT on sales exempt from VAT (UK only)',
        'OUTPUT' =>           'OUTPUT',
        'OUTPUT2' =>          'OUTPUT2',
        'SROUTPUT' =>         'SROUTPUT',
        'ZERORATEDOUTPUT' =>  'Sales made from overseas (UK only)',
        'RROUTPUT' =>         'Reduced rate VAT on sales (UK Only)',
        'ZERORATED' =>        'Zero-rated supplies/sales from overseas (NZ Only)',
        'ECZROUTPUT' =>       'Zero-rated EC Income (UK only)'
      } unless defined?(TAX_TYPE)

      set_primary_key :account_id

      guid    :account_id
      string  :code
      string  :name
      string  :type
      string  :class, :internal_name => :account_class
      string  :status
      string  :currency_code
      string  :tax_type
      string  :description
      string  :system_account
      boolean :enable_payments_to_account
      boolean :show_in_expense_claims
      string  :bank_account_number
      string  :reporting_code
      string  :reporting_code_name
      datetime_utc :updated_date_utc, api_name: 'UpdatedDateUTC'

      # validates_inclusion_of :status, :in => ACCOUNT_STATUSES, :unless => :new_record?

      public
        def archive!
          archive_account
        end

        def update
          clear_status
          super
        end

      protected
        def archive_account
          # remove all keys / data
          clear_account

          self.status = "ARCHIVED"
          self.save
        end

        # Removes all values from objects, except ID
        def clear_account
          self.status = nil
          self.code = nil
          self.type = nil
          self.name = nil
          self.account_class = nil
          self.currency_code = nil
          self.tax_type = nil
          self.description = nil
          self.system_account = nil
          self.enable_payments_to_account = nil
          self.show_in_expense_claims = nil
          self.bank_account_number = nil
          self.reporting_code = nil
          self.reporting_code_name = nil
          self.updated_date_utc = nil
        end

        def clear_status
          self.status = nil
        end

    end

  end
end
