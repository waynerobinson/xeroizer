require 'rubygems'
require 'forwardable'
require 'oauth'
require 'oauth/signature/rsa/sha1'
require 'nokogiri'

$: << File.expand_path(File.dirname(__FILE__)) 

require 'xeroizer/oauth'
require 'xeroizer/http_encoding_helper'
require 'xeroizer/http'
