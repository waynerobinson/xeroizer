module Xeroizer
  module Record
    class TaxComponentModel < BaseModel
      set_permissions :read
    end

    class TaxComponent < Base
      string      :name
      decimal     :rate
      boolean     :is_compound
      boolean     :is_non_recoverable
    end
  end
end
