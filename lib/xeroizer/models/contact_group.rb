module Xeroizer
  module Record

    class ContactGroupModel < BaseModel
      set_permissions :read
    end

    class ContactGroup < Base

      guid :contact_group_id
      string :name
      string :status

      set_primary_key :contact_group_id
      list_contains_summary_only true
      has_many :contacts, :list_complete => true

      # Adding Contact uses different API endpoint
      # https://developer.xero.com/documentation/api/contactgroups#PUT
      def add_contact(contact)
        @contacts ||= []
        @contacts <<  contact
      end

      def delete
        status = 'DELETED'
      end

      def name=(value)
        @modified = true unless @attributes[:name].nil? or @attributes[:name] == value
        @attributes[:name] = value
      end

      def status=(value)
        @modified = true unless @attributes[:status].nil? or @attributes[:status] == value
        @attributes[:status] = value
      end

      def save!
        super if new_record? or @modified
        @modified = false
        if @contacts
          req = cg_xml
          app = parent.application
          res = app.http_put(app.client, "#{parent.url}/#{CGI.escape(id)}/Contacts", req)
          parse_save_response(res)
        end
      end

      def cg_xml
        b = Builder::XmlMarkup.new(:indent => 2)
        b.tag!('Contacts') do
          @contacts.each do |c|
            b.tag!('Contact') do
              b.tag!('ContactID', c.id)
            end
          end
        end
      end

    end

  end
end
