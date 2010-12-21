module Xeroizer
  module Record
    
    class Base
      
      include ClassLevelInheritableAttributes
      inheritable_attributes :fields, :possible_primary_keys, :primary_key_name, :summary_only, :validators
                 
      attr_reader :attributes
      attr_reader :parent
      attr_accessor :errors
      attr_accessor :complete_record_downloaded
      
      include ModelDefinitionHelper
      include RecordAssociationHelper
      include ValidationHelper
      include XmlHelper
      
      class << self

        # Build a record with attributes set to the value of attributes.
        def build(attributes, parent)
          record = new(parent)
          attributes.each do | key, value |
            record.send("#{key}=".to_sym, value)
          end
          record
        end
        
      end
      
      public
      
        def initialize(parent)
          @parent = parent
          @attributes = {}
        end
        
        def new_model_class(model_name)
          Xeroizer::Record.const_get("#{model_name}Model".to_sym).new(parent.application, model_name.to_s)
        end
        
        def [](attribute)
          self.send(attribute)
        end
        
        def []=(attribute, value)
          self.send("#{attribute}=", value)
        end
        
        def new_record?
          self.class.possible_primary_keys.all? { | key | @attributes[key].nil? }
        end
        
        # Check to see if the complete record is downloaded.
        def complete_record_downloaded?
          if !!self.class.list_contains_summary_only?
            !!complete_record_downloaded
          else
            true
          end
        end
        
        # Downloads the complete record if we only have a summary of the record.
        def download_complete_record!
          record = self.parent.find(self.id)
          @attributes = record.attributes
          @complete_record_downloaded = true
          self
        end
        
        def save
          if new_record?
            create
          else
            update
          end
        end
                
      protected
      
        # Attempt to create a new record.
        def create
          parse_save_response(parent.http_put(to_xml))
        end
        
        # Attempt to update an existing record.
        def update
          if self.class.possible_primary_keys && self.class.possible_primary_keys.all? { | possible_key | self[possible_key].nil? }
            raise RecordKeyMustBeDefined.new(self.class.possible_primary_keys)
          end
          
          parse_save_response(parent.http_post(to_xml))
        end
        
        # Parse the response from a create/update request.
        def parse_save_response(response_xml)
          record = parent.parse_response(response_xml)
          record = record.first if record.is_a?(Array)
          if record && record.is_a?(self.class)
            @attributes = record.attributes
          end
          self
        end
                     
    end
    
  end
end