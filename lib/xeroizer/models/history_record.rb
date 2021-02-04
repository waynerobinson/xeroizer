module Xeroizer
  module Record

    class HistoryRecordModel < BaseModel

      module Extensions
        def history(id)
          application.HistoryRecord.history(url, id)
        end

        def add_note(id, details)
          application.HistoryRecord.add_note(url, id, details)
        end
      end

      set_permissions :read

      # History Records can only be added, no update or delete is possible
      def create_method
        :http_put
      end

      def history(url, id)
        response_xml = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}/history")

        response = parse_response(response_xml)

        response.response_items
      end

      def add_note(url, id, details)
        record = build(details: details)
        xml = to_bulk_xml([record])
        response_xml = @application.http_put(@application.client,
                                              "#{url}/#{CGI.escape(id)}/history",
                                              xml,
                                              raw_body: true
                                             )
        response = parse_response(response_xml)
        if (response_items = response.response_items) && response_items.size > 0
          response_items.size == 1 ? response_items.first : response_items
        else
          response
        end
      end

    end

    class HistoryRecord < Base

      module Extensions
        def history
          parent.history(id)
        end

        def add_note(details)
          parent.add_note(id, details)
        end
      end

      datetime_utc :date_utc, :api_name => 'DateUTC'
      string :date_utc_string, :api_name => 'DateUTCString'
      string :changes
      string :user
      string :details

      validates_presence_of :details

    end

  end
end