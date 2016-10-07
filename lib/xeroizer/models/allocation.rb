module Xeroizer
  module Record
    class AllocationModel < BaseModel
    end

    class Allocation < Base
      decimal :applied_amount
      datetime :date
      belongs_to :invoice


      validates_presence_of :invoice

      def invoice_id
        invoice.id if invoice
      end

      def invoice_number
        invoice.invoice_number if invoice
      end
    end
  end
end
