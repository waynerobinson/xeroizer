module Xeroizer
  module Report
    module RowXmlHelper
    
      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
      
        public
      
          def build_from_node(node, report, parent = nil)
            row_type = node.xpath('RowType').first.text
            row = nil
            case row_type
              when 'Header'
                row = HeaderRow.new(report);
                parent.header = row if parent
                report.header ||= row
                
              when 'Section'
                row = SectionRow.new(report)
                row.header = report.header
                report.sections << row
                
              when 'SummaryRow'
                row = SummaryRow.new(report);
                row.header = report.header
                if parent
                  parent.summary = row
                  
                  # Also add this summary row to the report if the section
                  # title is blank and the report doesn't already have one.
                  if parent.title.to_s == '' && report.summary.nil?
                    report.summary = row
                  end
                else
                  report.summary = row
                end
                
              else
                row = Row.new(report)
                row.header = report.header
                
            end
            row.parent = parent
            
            node.elements.each do | element |
              case element.name.to_s
                when 'RowType'  then row.type = element.text
                when 'Title'    then row.title = element.text
                when 'Rows'
                  element.elements.each do | row_node |
                    row.rows << Row.build_from_node(row_node, report, row)
                  end
                  
                when 'Cells'
                  element.elements.each do | cell_node |
                    row.cells << Cell.build_from_node(cell_node)
                  end
                  
              end
            end
                        
            row
          end
                  
      end
    
      module InstanceMethods
      end
    
    end
  end
end