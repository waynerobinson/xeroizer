module Xeroizer
  module Record
    module Payroll

      class WorkLocationModel < PayrollBaseModel

      end

      class WorkLocation < PayrollBase

        guid        :work_location_id
        boolean     :is_primary
        string      :street_address
        string      :suite_or_apt_or_unit
        string      :city
        string      :state
        string      :zip
        decimal     :latitude
        decimal     :longitude

        validates_presence_of :work_location_id, :unless => :new_record?
      end
    end
  end
end