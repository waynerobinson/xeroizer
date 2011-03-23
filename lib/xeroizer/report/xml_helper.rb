module Xeroizer
  module Report
    module XmlHelper
      
      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        
        public
        
          def build_from_node(node, factory)
            report = new(factory)
            
            extract_report_details(report, node)
            
            rows = node.xpath("Rows/Row")
            extract_rows(report, rows) if rows && rows.size > 0
            
            report
          end

        protected
        
          # Extract header details for the report response.
          def extract_report_details(report, node)
            node.elements.each do | element |
              case element.name.to_s
                when 'ReportID'       then report.id = element.text
                when 'ReportName'     then report.name = element.text
                when 'ReportType'     then report.type = element.text
                when 'ReportDate'     then report.date = Date.parse(element.text)
                when 'UpdatedDateUTC' then report.updated_at = Time.parse(element.text)
                when 'ReportTitles'
                  element.elements.each do | title_element |
                    report.titles << title_element.text
                  end
              end
            end
          end
          
          # Extract the report rows
          def extract_rows(report, rows)
            rows.each do | row_node |
              report.rows << Row.build_from_node(row_node, report)
            end
          end
          
      end
      
      module InstanceMethods
      end
      
    end
  end
end