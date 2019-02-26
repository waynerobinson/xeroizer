module Xeroizer
  module Record

    class PrepaymentModel < BaseModel

      set_xml_root_name 'Prepayments'
      set_permissions :read

    end

    class Prepayment < Base
      set_primary_key :prepayment_id

      guid          :prepayment_id
      date          :date
      string        :status
      string        :line_amount_types
      decimal       :sub_total
      decimal       :total_tax
      decimal       :total
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string        :currency_code
      datetime_utc  :fully_paid_on_date
      string        :type
      string        :reference
      decimal       :currency_rate
      decimal       :remaining_credit
      decimal       :applied_amount
      boolean       :has_attachments

      belongs_to    :contact
      has_many      :line_items
      has_many      :payments

      def contact_id
        contact.id if contact
      end

    end
  end
end
