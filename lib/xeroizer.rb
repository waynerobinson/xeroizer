require 'rubygems'
require 'forwardable'
require "active_support/inflector"
require 'oauth'
require 'oauth/signature/rsa/sha1'
require 'nokogiri'
require 'time'
require 'bigdecimal'
require 'cgi'

$: << File.expand_path(File.dirname(__FILE__)) 

require 'xeroizer/nokogiri_utils'
require 'xeroizer/oauth'
require 'xeroizer/http_encoding_helper'
require 'xeroizer/http'
require 'xeroizer/exceptions'

require 'xeroizer/record/base'
require 'xeroizer/record/organisation'
require 'xeroizer/record/tracking_category'
require 'xeroizer/record/option'
require 'xeroizer/record/phone'
require 'xeroizer/record/address'
require 'xeroizer/record/contact'
require 'xeroizer/record/application_helper'

require 'xeroizer/response'

require 'xeroizer/generic_application'
require 'xeroizer/public_application'
require 'xeroizer/private_application'
require 'xeroizer/partner_application'
