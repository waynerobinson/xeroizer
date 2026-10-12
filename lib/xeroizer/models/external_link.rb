# frozen_string_literal: true

module Xeroizer
  module Record
    class ExternalLinkModel < BaseModel
    end

    class ExternalLink < Base
      string :url
      string :description
    end
  end
end
