module Xeroizer
  module Record
    module Payroll
    
      class HomeAddressModel < PayrollBaseModel

      end
      
      class HomeAddress < PayrollBase
        
        STATE_ABBREVIATION = {
          'ACT' => 'Australian Capital Territory',
          'NSW' => 'New South Wales',
          'NT' => 'Northern Territory',
          'QLD' => 'Queensland',
          'SA' => 'South Australia',
          'TAS' => 'Tasmania',
          'VIC' => 'Victoria',
          'WA' => 'Western Australia',
        } unless defined?(STATE_ABBREVIATION)
        STATE_ABBREVIATIONS = STATE_ABBREVIATION.keys.sort

        string      :address_line1
        string      :address_line2
        string      :address_line3
        string      :address_line4
        string      :city
        string      :region
        string      :postal_code
        string      :country

        validates_length_of :address_line1, :address_line2, :address_line3, :address_line4, length: { maximum: 100 }, :allow_blanks => true
        validates_length_of :city, length: { maximum: 50 }, :allow_blanks => true
        validates_inclusion_of :region, :in => STATE_ABBREVIATIONS, :allow_blanks => true
        validates_length_of :postal_code, length: { maximum: 4 }, :allow_blanks => true
      end

    end 
  end
end
