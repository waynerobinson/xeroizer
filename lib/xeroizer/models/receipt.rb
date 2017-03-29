module Xeroizer
  module Record
    
    class ReceiptModel < BaseModel
        
      set_permissions :read, :write, :update
      
      include AttachmentModel::Extensions

    end
    
    class Receipt < Base
      
      include Attachment::Extensions
      
      set_primary_key :receipt_id
      set_possible_primary_keys :receipt_id, :receipt_number

      guid          :receipt_id
      string        :receipt_number
      string        :reference
      string        :status
      string        :line_amount_types
      decimal       :sub_total, :calculated => true
      decimal       :total_tax, :calculated => true
      decimal       :total, :calculated => true
      date          :date
      string        :url
      boolean       :has_attachments
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      
      belongs_to    :user
      belongs_to    :contact
      has_many      :line_items

      def contact_id
        contact.id if contact
      end

      def contact_name
        contact.name if contact
      end

      def user_firstname
        user.firstname if user
      end

      def user_lastname
        user.lastname if user
      end

      def user_id
        user.id if user
      end

    end
    
  end
end