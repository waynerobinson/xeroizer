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
      boolean       :has_attachments

      belongs_to    :contact
      has_many      :line_items
      has_many      :payments
      has_many      :allocations

      validates_associated :allocations, :allow_blanks => true

      public
        def contact_id
          contact.id if contact
        end

        def allocate
          if self.class.possible_primary_keys && self.class.possible_primary_keys.all? { | possible_key | self[possible_key].nil? }
            raise RecordKeyMustBeDefined.new(self.class.possible_primary_keys)
          end

          request = association_to_xml(:allocations)
          allocations_url = "#{parent.url}/#{CGI.escape(id)}/Allocations"

          log "[ALLOCATION SENT] (#{__FILE__}:#{__LINE__}) \r\n#{request}"
          response = parent.application.http_put(parent.application.client, allocations_url, request)
          log "[ALLOCATION RECEIVED] (#{__FILE__}:#{__LINE__}) \r\n#{response}"
          parse_save_response(response)
        end

    end
  end
end
