module Xeroizer
  module Record

    class OverpaymentModel < BaseModel

      set_xml_root_name 'Overpayments'
      set_api_controller_name 'Overpayment'
      set_permissions :read

    end

    class Overpayment < Base
      set_primary_key :overpayment_id

      guid          :overpayment_id
      date          :date
      string        :status
      string        :line_amount_types
      decimal       :sub_total
      decimal       :total_tax
      decimal       :total
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string        :currency_code
      string        :type
      decimal       :remaining_credit
      boolean       :has_attachments

      belongs_to    :contact
      belongs_to    :invoice
      has_many      :allocations
      has_many      :line_items

      def contact_id
        contact.id if contact
      end

    end
  end
end