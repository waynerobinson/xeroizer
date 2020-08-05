require "xeroizer/models/attachment"

module Xeroizer
  module Record

    class QuoteModel < BaseModel
      set_permissions :read, :write, :update

      include AttachmentModel::Extensions

      public

        # Retrieve the PDF version of the quote matching the `id`.
        # @param [String] id quote's ID.
        # @param [String] filename optional filename to store the PDF in instead of returning the data.
        def pdf(id, filename = nil)
          pdf_data = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", :response => :pdf)
          if filename
            File.open(filename, "wb") { | fp | fp.write pdf_data }
            nil
          else
            pdf_data
          end
        end

    end

    class Quote < Base

      QUOTE_STATUS = {
        'DRAFT' =>    'A draft quote (default)',
        'DELETED' =>  'A deleted quote',
        'SENT' =>     'A quote that is marked as sent',
        'DECLINED' => 'A quote that was declined by the customer',
        'ACCEPTED' => 'A quote that was accepted by the customer',
        'INVOICED' => 'A quote that has been invoiced'
      } unless defined?(QUOTE_STATUS)
      QUOTE_STATUSES = QUOTE_STATUS.keys.sort

      include Attachment::Extensions

      set_primary_key :quote_id
      set_possible_primary_keys :quote_id, :quote_number
      list_contains_summary_only false

      guid         :quote_id
      string       :quote_number
      string       :reference
      guid         :branding_theme_id
      date         :date
      date         :expiry_date
      string       :status
      string       :line_amount_types
      decimal      :sub_total
      decimal      :total_tax
      decimal      :total
      decimal      :total_discount
      datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string       :currency_code
      decimal      :currency_rate
      string       :title
      string       :summary
      string       :terms
      boolean      :has_attachments

      belongs_to   :contact
      has_many     :line_items

      # Retrieve the PDF version of this quote.
      # @param [String] filename optional filename to store the PDF in instead of returning the data.
      def pdf(filename = nil)
        parent.pdf(id, filename)
      end
    end
  end
end
