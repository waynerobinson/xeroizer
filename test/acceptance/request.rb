Request = Struct.new("Request", :uri, :verb, :headers, :body)
Response = Struct.new("Response", :status, :headers, :body)
