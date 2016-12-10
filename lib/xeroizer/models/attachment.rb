module Xeroizer
  module Record

    class AttachmentModel < BaseModel

      module Extensions
        def attach_data(id, filename, data, content_type = "application/octet-stream", options = {})
          application.Attachment.attach_data(url, id, filename, data, content_type, options)
        end

        def attach_file(id, filename, path, content_type = "application/octet-stream", options = {})
          application.Attachment.attach_file(url, id, filename, path, content_type, options)
        end

        def attachments(id)
          application.Attachment.attachments_for(url, id)
        end
      end

      set_permissions :read

      def attach_data(url, id, filename, data, content_type, options = {})
        options = { include_online: false }.merge(options)

        response_xml = @application.http_put(@application.client,
                                              "#{url}/#{CGI.escape(id)}/Attachments/#{CGI.escape(filename)}",
                                              data,
                                              :raw_body => true, :content_type => content_type, "IncludeOnline" => options[:include_online]
                                             )
        response = parse_response(response_xml)
        if (response_items = response.response_items) && response_items.size > 0
          response_items.size == 1 ? response_items.first : response_items
        else
          response
        end
      end

      def attach_file(url, id, filename, path, content_type, options = {})
        attach_data(url, id, filename, File.read(path), content_type, options)
      end

      def attachments_for(url, id)
        response_xml = @application.http_get(@application.client,
                                             "#{url}/#{CGI.escape(id)}/Attachments")

        response = parse_response(response_xml)
        if (response_items = response.response_items) && response_items.size > 0
          response_items
        else
          []
        end
      end

    end

    class Attachment < Base

      module Extensions
        def attach_file(filename, path, content_type = "application/octet-stream", options = {})
          parent.attach_file(id, filename, path, content_type, options)
        end

        def attach_data(filename, data, content_type = "application/octet-stream", options = {})
          parent.attach_data(id, filename, data, content_type, options)
        end

        def attachments
          parent.attachments(id)
        end
      end

      set_primary_key :attachment_id

      guid    :attachment_id
      string  :file_name
      string  :url
      string  :mime_type
      integer :content_length

      # Retrieve the attachment data.
      # @param [String] filename optional filename to store the attachment in instead of returning the data.
      def get(filename = nil)
        data = parent.application.http_get(parent.application.client, url)
        if filename
          File.open(filename, "wb") { | fp | fp.write data }
          nil
        else
          data
        end
      end

    end

  end
end