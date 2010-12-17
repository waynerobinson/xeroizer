require 'rubygems'
require 'forwardable'
require "active_support/inflector"
require 'oauth'
require 'oauth/signature/rsa/sha1'
require 'nokogiri'
require 'builder'
require 'time'
require 'bigdecimal'
require 'cgi'

$: << File.expand_path(File.dirname(__FILE__)) 

require 'nokogiri_utils'
require 'class_level_inheritable_attributes'
require 'xeroizer/oauth'
require 'xeroizer/http_encoding_helper'
require 'xeroizer/http'
require 'xeroizer/exceptions'

require 'xeroizer/record/model_definition_helper'
require 'xeroizer/record/record_association_helper'
require 'xeroizer/record/xml_helper'
require 'xeroizer/record/base_model'
require 'xeroizer/record/base'
require 'xeroizer/record/application_helper'

# Include models
Dir.foreach(File.join(File.dirname(__FILE__), 'xeroizer/models/')) { | file | require "xeroizer/models/#{file}" if file =~ /\.rb$/ }

require 'xeroizer/response'

require 'xeroizer/generic_application'
require 'xeroizer/public_application'
require 'xeroizer/private_application'
require 'xeroizer/partner_application'
