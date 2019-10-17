require "pp"
require "logger"
require 'rubygems'
require 'debugger'
require 'net-http-spy'

Net::HTTP.http_logger_options = {verbose: true, body: true, trace: true}

require File.dirname(__FILE__) + "/../lib/xeroizer"

xero = Xeroizer::PrivateApplication.new(
          'JRKZQGSECLTD6PZBLVRDKZGGELNRI1',
          'QXJLLZK63AM29DO0GPRIR3ABPNZYRM',
          File.dirname(__FILE__) + "/../privatekey.pem"
       ).payroll

#xero = Xeroizer::PublicApplication.new(
#          'JRKZQGSECLTD6PZBLVRDKZGGELNRI1',
#          'QXJLLZK63AM29DO0GPRIR3ABPNZYRM'
#       ).payroll
#url = xero.request_token(:oauth_callback => 'http://developer.xero.com/payroll-api/')

xero.logger = Logger.new(STDOUT)

puts xero.Employee.url
puts xero.Timesheet.url