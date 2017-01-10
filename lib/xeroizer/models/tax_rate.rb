module Xeroizer
  module Record

    class TaxRateModel < BaseModel

      set_permissions :read

      # TaxRates can be created using either POST or PUT.
      # POST will also silently update the tax, which can
      # be unexpected.  PUT is only for create.
      def create_method
        :http_put
      end
    end

    class TaxRate < Base
      set_primary_key :name
      set_possible_primary_keys :tax_type, :name

      string  :name
      string  :tax_type
      string  :report_tax_type # Read-only except for AU, NZ, and UK versions
      string  :status
      boolean :can_apply_to_assets
      boolean :can_apply_to_equity
      boolean :can_apply_to_expenses
      boolean :can_apply_to_liabilities
      boolean :can_apply_to_revenue
      decimal :display_tax_rate
      decimal :effective_rate

      has_many :tax_components
    end

  end
end
