module Xeroizer
  module Report
    module CellXmlHelper
    
      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
      
        public
      
          # Create an instance of Cell from the node.
          #
          # Additionally, parse the attributes and return them as a hash to the 
          # cell. If a cell's attributes look like:
          #
          #     <Attributes>
          #       <Attribute>
          #         <Value>1335b8b2-4d63-4af8-937f-04087ae2e36e</Value>
          #         <Id>account</Id>
          #       </Attribute>
          #     </Attributes>
          # 
          # Return a hash like:
          #
          #     {
          #       'account' => '1335b8b2-4d63-4af8-937f-04087ae2e36e'
          #     }
          def build_from_node(node)
            cell = new
            node.elements.each do | element |
              case element.name.to_s
                when 'Value' then cell.value = parse_value(element.text)
                when 'Attributes'
                  element.elements.each do | attribute_node |
                    (id, value) = parse_attribute(attribute_node)
                    cell.attributes[id] = value
                  end
              end
            end
            cell
          end
          
        protected

          def parse_value(value)
            case value
              when /^[-]?\d+(\.\d+)?$/                      then BigDecimal(value)
              when /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/  then Time.xmlschema(value)
              else                                          value
            end
          end
        
          def parse_attribute(attribute_node)
            id = nil
            value = nil
            attribute_node.elements.each do | element |
              case element.name.to_s
                when 'Id'     then id = element.text
                when 'Value'  then value = element.text
              end
            end
            [id, value]
          end
      end
    
      module InstanceMethods
      end
    
    end
  end
end
