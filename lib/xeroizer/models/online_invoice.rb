module Xeroizer
  module Record
    
    class OnlineInvoiceModel < BaseModel

      module Extensions
      	def online_invoice_url(id)
      		application.OnlineInvoice.online_invoice_url(url, id)
      	end
      end
    
      set_permissions :read

      def online_invoice_url(url, id)
		response_xml = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}/OnlineInvoice")
		
		response = parse_response(response_xml)

		response.response_items.first
      end
    
    end
    
    class OnlineInvoice < Base

      module Extensions
      	def online_invoice_url
      	  parent.online_invoice_url(id)
      	end
      end

      string   :online_invoice_url

    end
    
  end
end