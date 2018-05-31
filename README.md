Xeroizer API Library ![Project status](http://stillmaintained.com/waynerobinson/xeroizer.png) [![Build Status](https://travis-ci.org/waynerobinson/xeroizer.svg)](https://travis-ci.org/waynerobinson/xeroizer)
====================

**Homepage**: 		[http://waynerobinson.github.com/xeroizer](http://waynerobinson.github.com/xeroizer)		
**Git**: 					[git://github.com/waynerobinson/xeroizer.git](git://github.com/waynerobinson/xeroizer.git)		
**Github**: 			[https://github.com/waynerobinson/xeroizer](https://github.com/waynerobinson/xeroizer)		
**Author**: 			Wayne Robinson [http://www.wayne-robinson.com](http://www.wayne-robinson.com)		
**Contributors**: See Contributors section below	
**Copyright**:    2007-2013
**License**:      MIT License		

Introduction
------------

This library is designed to help ruby/rails based applications communicate with the publicly available API for Xero.

If you are unfamiliar with the Xero API, you should first read the documentation located at http://developer.xero.com.

Installation
------------

	gem install xeroizer

Basic Usage
-----------

```ruby
require 'rubygems'
require 'xeroizer'

# Create client (used to communicate with the API).
client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)

# Retrieve list of contacts (note: all communication must be made through the client).
contacts = client.Contact.all(:order => 'Name')
```
	
Authentication
--------------

Xero uses OAuth to authenticate API clients. The OAuth gem (with minor modification) by John Nunemaker ([http://github.com/jnunemaker/twitter](http://github.com/jnunemaker/twitter)) is used in this library. If you've used this before, things will all seem very familar.

There are three methods of authentication detailed below:

### All: Consumer Key/Secret

All methods of authentication require your OAuth consumer key and secret. This can be found for your application 
in the API management console at [http://api.xero.com](http://api.xero.com).

### Public Applications

Public applications use a 3-legged authorisation process. A user will need to authorise your 
application against each organisation that you want access to. Your application can have access 
to many organisations at once by going through the authorisation process for each organisation.

The access token received will expire after 30 minutes. If you want access for longer you will need
the user to re-authorise your application.

Authentication occurs in 3 steps:

```ruby
client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)

# 1. Get a RequestToken from Xero. :oauth_callback is the URL the user will be redirected to
#    after they have authenticated your application.
#
#    Note: The callback URL's domain must match that listed for your application in http://api.xero.com
#          otherwise the user will not be redirected and only be shown the authentication code.
request_token = client.request_token(:oauth_callback => 'http://yourapp.com/oauth/callback')

# 2. Redirect the user to the URL specified by the RequestToken.
#    
#    Note: example uses redirect_to method defined in Rails controllers.
redirect_to request_token.authorize_url

# 3. Exchange RequestToken for AccessToken.
#    This access token will be used for all subsequent requests but it is stored within the client
#    application so you don't have to record it. 
#
#    Note: This example assumes the callback URL is a Rails action.
client.authorize_from_request(request_token.token, request_token.secret, :oauth_verifier => params[:oauth_verifier])
```
	
You can now use the client to access the Xero API methods, e.g.

```ruby
contacts = client.Contact.all
```
	
#### Example Rails Controller

```ruby
class XeroSessionController < ApplicationController

	before_filter :get_xero_client
	
	public
	
		def new
			request_token = @xero_client.request_token(:oauth_callback => 'http://yourapp.com/xero_session/create')
			session[:request_token] = request_token.token
			session[:request_secret] = request_token.secret
			
			redirect_to request_token.authorize_url
		end
		
		def create
			@xero_client.authorize_from_request(
					session[:request_token], 
					session[:request_secret], 
					:oauth_verifier => params[:oauth_verifier] )
						
			session[:xero_auth] = {
					:access_token => @xero_client.access_token.token,
					:access_key => @xero_client.access_token.secret }
															
			session.data.delete(:request_token)
			session.data.delete(:request_secret)
		end
		
		def destroy
			session.data.delete(:xero_auth)
		end
		
	private
		
		def get_xero_client
			@xero_client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)
			
			# Add AccessToken if authorised previously.
			if session[:xero_auth]
				@xero_client.authorize_from_access(
					session[:xero_auth][:access_token], 
					session[:xero_auth][:access_key] )
			end
		end
end
```
	
#### Storing AccessToken 

You can store the access token/secret pair so you can access the API again without user intervention. Currently these
tokens are only valid for 30 minutes and will raise a `Xeroizer::OAuth::TokenExpired` exception if you try to access
the API beyond the token's expiry time.

If you want API access for longer consider creating a PartnerApplication which will allow you to renew tokens.

```ruby
access_key = client.access_token.token
access_secret = client.access_token.secret
```

### Private Applications

Private applications use a 2-legged authorisation process. When you register your application, you will select 
the organisation that is authorised to your application. This cannot be changed afterwards, although you can 
register another private application if you have multiple organisations. 

Note: You can only register organisations you are authorised to yourself.

Private applications require a private RSA keypair which is used to sign each request to the API. You can
generate this keypair on Mac OSX or Linux with OpenSSL. For example:

	openssl genrsa -out privatekey.pem 1024
	openssl req -newkey rsa:1024 -x509 -key privatekey.pem -out publickey.cer -days 365
	openssl pkcs12 -export -out public_privatekey.pfx -inkey privatekey.pem -in publickey.cer

You need to upload this `public_privatekey.pfx` file to your private application in [http://api.xero.com](http://api.xero.com).

Example usage:

```ruby
client = Xeroizer::PrivateApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET, "/path/to/privatekey.pem")
contacts = client.Contact.all
```

### Partner Applications

Partner applications use a combination of 3-legged authorisation and private key message signing.

You will need to contact Xero (network@xero.com) to get permission to create a partner application.

After you have followed the instructions provided by Xero for partner applications and uploaded your certificate you can
access the partner application in a similar way to public applications.

Authentication occcurs in 3 steps:

```ruby
client = Xeroizer::PartnerApplication.new(
					YOUR_OAUTH_CONSUMER_KEY,
					YOUR_OAUTH_CONSUMER_SECRET, 
					"/path/to/privatekey.pem"
					)

# 1. Get a RequestToken from Xero. :oauth_callback is the URL the user will be redirected to
#    after they have authenticated your application.
#
#    Note: The callback URL's domain must match that listed for your application in http://api.xero.com
#          otherwise the user will not be redirected and only be shown the authentication code.
request_token = client.request_token(:oauth_callback => 'http://yourapp.com/oauth/callback')

# 2. Redirect the user to the URL specified by the RequestToken.
#    
#    Note: example uses redirect_to method defined in Rails controllers.
redirect_to request_token.authorize_url

# 3. Exchange RequestToken for AccessToken.
#    This access token will be used for all subsequent requests but it is stored within the client
#    application so you don't have to record it. 
#
#    Note: This example assumes the callback URL is a Rails action.
client.authorize_from_request(request_token.token, request_token.secret, :oauth_verifier => params[:oauth_verifier])
```

This AccessToken will last for 30 minutes however, when using the partner application API you can
renew this token. To be able to renew this token, you need to save the following data from this organisation's
AccessToken:

```ruby
session_handle = client.session_handle
access_key = client.access_token.token
access_secret = client.access_token.secret
```
	
Two other interesting attributes of the PartnerApplication client are:

> **`#expires_at`**:								Time this AccessToken will expire (usually 30 minutes into the future).		
> **`#authorization_expires_at`**:	How long this organisation has authorised you to access their data (usually 10 years into the future).		

#### AccessToken Renewal

Renewal of an access token requires knowledge of the previous access token generated for this organisation. To renew:

```ruby
# If you still have a client instance.
client.renew_access_token

# If you are renewing from stored token/session details.
client.renew_access_token(access_token, access_secret, session_handle)
```

This will invalidate the previous token and refresh the `access_key` and `access_secret` as specified in the
initial authorisation process. You must always know the previous token's details to renew access to this
session.

If you lose these details at any stage you can always reauthorise by redirecting the user back to the Xero OAuth gateway.

Retrieving Data
---------------

Each of the below record types is implemented within this library. To allow for multiple access tokens to be used at the same
time in a single application, the model classes are accessed from the instance of PublicApplication, PrivateApplication
or PartnerApplication. All class-level operations occur on this singleton. For example:

```ruby
xero = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)
xero.authorize_from_access(session[:xero_auth][:access_token], session[:xero_auth][:access_key])

contacts = xero.Contact.all(:order => 'Name')

new_contact = xero.Contact.build(:name => 'ABC Development')
saved = new_contact.save
```

### \#all([options])

Retrieves list of all records with matching options. 

**Note:** Some records (Invoice, CreditNote) only return summary information for the contact and no line items
when returning them this list operation. This library takes care of automatically retrieving the 
contact and line items from Xero on first access however, this first access has a large performance penalty
and will count as an extra query towards your 5,000/day and 60/minute request per organisation limit.

Valid options are:

> **:modified\_since**

> Records modified after this `Time` (must be specified in UTC).

> **:order**

> Field to order by. Should be formatted as Xero-based field (e.g. 'Name', 'ContactID', etc)

> **:where**

> __See *Where Filters* section below.__

### \#first([options])

This is a shortcut method for `all` and actually runs all however, this method only returns the
first entry returned by all and never an array.

### \#find(id)

Looks up a single record matching `id`. This ID can either be the internal GUID Xero uses for the record
or, in the case of Invoice, CreditNote and Contact records, your own custom reference number used when
creating these records.

### Where filters

#### Hash

You can specify find filters by providing the :where option with a hash. For example:

```ruby
invoices = Xero.Invoice.all(:where => {:type => 'ACCREC', :amount_due_is_not => 0})
```
	
will automatically create the Xero string:

	Type=="ACCREC"&&AmountDue<>0
	
The default method for filtering is the equality '==' operator however, these can be overridden
by modifying the postfix of the attribute name (as you can see for the :amount\_due field above).

	\{attribute_name}_is_not will use '<>'
	\{attribute_name}_is_greater_than will use '>'
	\{attribute_name}_is_greater_than_or_equal_to will use '>='
	\{attribute_name}_is_less_than will use '<'
	\{attribute_name}_is_less_than_or_equal_to will use '<='
	
	The default is '=='
	
**Note:** Currently, the hash-conversion library only allows for AND-based criteria and doesn't
take into account associations. For these, please use the custom filter method below.

#### Custom Xero-formatted string

Xero allows advanced custom filters to be added to a request. The where parameter can reference any XML element
in the resulting response, including all nested XML elements.

**Example 1: Retrieve all invoices for a specific contact ID:**

		invoices = xero.Invoice.all(:where => 'Contact.ContactID.ToString()=="cd09aa49-134d-40fb-a52b-b63c6a91d712"')
	
**Example 2: Retrieve all unpaid ACCREC Invoices against a particular Contact Name:**
	
		invoices = xero.Invoice.all(:where => 'Contact.Name=="Basket Case" && Type=="ACCREC" && AmountDue<>0')
	
**Example 3: Retrieve all Invoices PAID between certain dates**
	
		invoices = xero.Invoice.all(:where => 'FullyPaidOnDate>=DateTime.Parse("2010-01-01T00:00:00")&&FullyPaidOnDate<=DateTime.Parse("2010-01-08T00:00:00")')
	
**Example 4: Retrieve all Invoices using Paging (batches of 100)**

		invoices = xero.Invoice.find_in_batches({page_number: 1}) do |invoice_batch|
		  invoice_batch.each do |invoice|
		    ...
		  end
		end
				
**Example 5: Retrieve all Bank Accounts:**
	
		accounts = xero.Account.all(:where => 'Type=="BANK"')
	
**Example 6: Retrieve all DELETED or VOIDED Invoices:**
	
		invoices = xero.Invoice.all(:where => 'Status=="VOIDED" OR Status=="DELETED"')
	
**Example 7: Retrieve all contacts with specific text in the contact name:**

		contacts = xero.Contact.all(:where => 'Name.Contains("Peter")')
		contacts = xero.Contact.all(:where => 'Name.StartsWith("Pet")')
		contacts = xero.Contact.all(:where => 'Name.EndsWith("er")')

Associations
------------

Records may be associated with each other via two different methods, `has_many` and `belongs_to`.

**has\_many example:**

```ruby
invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
invoice.line_items.each do | line_item |
	puts "Line Description: #{line_item.description}"
end
```
	
**belongs\_to example:**

```ruby
invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
puts "Invoice Contact Name: #{invoice.contact.name}"
```

Attachments
------------
Files or raw data can be attached to record types
**attach\_data examples:**
```ruby
invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
invoice.attach_data("example.txt", "This is raw data", "txt")
```

```ruby
attach_data('cd09aa49-134d-40fb-a52b-b63c6a91d712', "example.txt", "This is raw data", "txt")
```

**attach\_file examples:**
```ruby
invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
invoice.attach_file("example.png", "/path/to/image.png", "image/png")
```

```ruby
attach_file('cd09aa49-134d-40fb-a52b-b63c6a91d712', "example.png", "/path/to/image.png", "image/png")
```

**include with online invoice**
To include an attachment with an invoice set include_online parameter to true within the options hash
```ruby
invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
invoice.attach_file("example.png", "/path/to/image.png", "image/png", { include_online: true })
```

Creating/Updating Data
----------------------

### Creating

New records can be created like:

```ruby
contact = xero.Contact.build(:name => 'Contact Name')
contact.first_name = 'Joe'
contact.last_name = 'Bloggs'
contact.add_address(:type => 'STREET', :line1 => '12 Testing Lane', :city => 'Brisbane')
contact.add_phone(:type => 'DEFAULT', :area_code => '07', :number => '3033 1234')
contact.add_phone(:type => 'MOBILE', :number => '0412 123 456')
contact.save
```
	
To add to a `has_many` association use the `add_{association}` method. For example:

```ruby
contact.add_address(:type => 'STREET', :line1 => '12 Testing Lane', :city => 'Brisbane')
```
	
To add to a `belongs_to` association use the `build_{association}` method. For example:
	
```ruby
invoice.build_contact(:name => 'ABC Company')
```

### Updating
	
If the primary GUID for the record is present, the library will attempt to update the record instead of
creating it. It is important that this record is downloaded from the Xero API first before attempting
an update. For example:

```ruby
contact = xero.Contact.find("cd09aa49-134d-40fb-a52b-b63c6a91d712")
contact.name = "Another Name Change"
contact.save
```
	
Have a look at the models in `lib/xeroizer/models/` to see the valid attributes, associations and 
minimum validation requirements for each of the record types.

### Bulk Creates & Updates

Xero has a hard daily limit on the number of API requests you can make (currently 5,000 requests
per account per day). To save on requests, you can batch creates and updates into a single PUT or
POST call, like so:

```ruby
contact1 = xero.Contact.create(some_attributes)
xero.Contact.batch_save do
  contact1.email_address = "foo@bar.com"
  contact2 = xero.Contact.build(some_other_attributes)
  contact3 = xero.Contact.build(some_more_attributes)
end
```

`batch_save` will issue one PUT request for every 2,000 unsaved records built within its block, and one
POST request for every 2,000 existing records that have been altered within its block. If any of the
unsaved records aren't valid, it'll return `false` before sending anything across the wire;
otherwise, it returns `true`. `batch_save` takes one optional argument: the number of records to
create/update per request. (Defaults to 2,000.)

If you'd rather build and send the records manually, there's a `save_records` method:
```ruby
contact1 = xero.Contact.build(some_attributes)
contact2 = xero.Contact.build(some_other_attributes)
contact3 = xero.Contact.build(some_more_attributes)
xero.Contact.save_records([contact1, contact2, contact3])
```
It has the same return values as `batch_save`.

### Errors

If a record doesn't match its internal validation requirements, the `#save` method will return
`false` and the `#errors` attribute will be populated with what went wrong.

For example:

```ruby
contact = xero.Contact.build
saved = contact.save

# contact.errors will contain [[:name, "can't be blank"]]
```
	
\#errors\_for(:attribute\_name) is a helper method to return just the errors associated with
that attribute. For example:

```ruby
contact.errors_for(:name) # will contain ["can't be blank"]
```

If something goes really wrong and the particular validation isn't handled by the internal
validators then the library may raise a `Xeroizer::ApiException`.

Example Use Cases
-------

Creating & Paying an invoice:

```ruby
contact = xero.Contact.first

# Build the Invoice, add a LineItem and save it
invoice = xero.Invoice.build(:type => "ACCREC", :contact => contact, :date => DateTime.new(2017,10,19), :due_date => DateTime.new(2017,11,19))

invoice.add_line_item(:description => 'test', :unit_amount => '200.00', :quantity => '1', :account_code => '200')

invoice.save

# An invoice created without a status will default to 'DRAFT'
invoice.approved?

# Payments can only be created against 'AUTHROISED' invoices
invoice.approve!

# Find the first bank account
bank_account = xero.Account.first(:where => {:type => 'BANK'})

# Create & save the payment
payment = xero.Payment.build(:invoice => invoice, :account => bank_account, :amount => '220.00')
payment.save

# Reload the invoice from the Xero API
invoice = xero.Invoice.find(invoice.id)

# Invoice status is now "PAID" & Payment details have been returned as well
invoice.status
invoice.payments.first
invoice.payments.first.date
```

Reports
-------

All Xero reports except GST report can be accessed through Xeroizer.

Currently, only generic report access functionality exists. This will be extended
to provide a more report-specific version of the data in the future (public submissions
are welcome).

Reports are accessed like the following example:

```ruby
trial_balance = xero.TrialBalance.get(:date => DateTime.new(2011,3,21))

# Array containing report headings.
trial_balance.header.cells.map { | cell | cell.value }

# Report rows by section
trial_balance.sections.each do | section |
	puts "Section Title: #{section.title}"
	section.rows.each do | row |
		puts "\t#{row.cells.map { | cell | cell.value }.join("\t")}"
	end
end

# Summary row (if only one on the report)
trial_balance.summary.cells.map { | cell | cell.value }

# All report rows (including HeaderRow, SectionRow, Row and SummaryRow)
trial_balance.rows.each do | row |
	case row
		when Xeroizer::Report::HeaderRow
			# do something with header
			
		when Xeroizer::Report::SectionRow
			# do something with section, will need to step into the rows for this section
			
		when Xeroizer::Report::Row
			# do something for standard report rows
			
		when Xeroizer::Report::SummaryRow
			# do something for summary rows
			
	end
end
```

Xero API Rate Limits
--------------------

The Xero API imposes the following limits on calls per organisation:

* A limit of 60 API calls in any 60 second period
* A limit of 5000 API calls in any 24 hour period

By default, the library will raise a `Xeroizer::OAuth::RateLimitExceeded`
exception when one of these limits is exceeded.

If required, the library can handle these exceptions internally by sleeping
for a configurable number of seconds and then repeating the last request.
You can set this option when initializing an application:

```ruby
# Sleep for 2 seconds every time the rate limit is exceeded.
client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY,
                                         YOUR_OAUTH_CONSUMER_SECRET,
                                         :rate_limit_sleep => 2)
```

Xero API Nonce Used
-------------------

The Xero API seems to reject requests due to conflicts on occasion.

By default, the library will raise a `Xeroizer::OAuth::NonceUsed`
exception when one of these limits is exceeded.

If required, the library can handle these exceptions internally by sleeping 1 second and then repeating the last request.
You can set this option when initializing an application:

```ruby
# Sleep for 2 seconds every time the rate limit is exceeded.
client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY,
                                         YOUR_OAUTH_CONSUMER_SECRET,
                                         :nonce_used_max_attempts => 3)
```


Logging
---------------

You can add an optional parameter to the Xeroizer Application initialization, to pass a logger object that will need to respond_to :info. For example, in a rails app:

```ruby
XeroLogger = Logger.new('log/xero.log', 'weekly')
client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY,
                                         YOUR_OAUTH_CONSUMER_SECRET,
                                         :logger => XeroLogger)
```

HTTP Callbacks
--------------------

You can provide "before", "after" and "around" callbacks which will be invoked every
time Xeroizer makes an HTTP request, which is potentially useful for both
throttling and logging:

```ruby
Xeroizer::PublicApplication.new(
  credentials[:key], credentials[:secret],
  before_request: ->(request) { puts "Hitting this URL: #{request.url}" },
  after_request: ->(request, response) { puts "Got this response: #{response.code}" },
  around_request: -> (request, &block)  { puts "About to send request"; block.call; puts "After request"}
)
```

The `request` parameter is a custom Struct with `url`, `headers`, `body`,
and `params` methods. The `response` parameter is a Net::HTTPResponse object.


Unit Price Precision
--------------------

By default, the API accepts unit prices (UnitAmount) to two decimals places. If you require greater precision, you can opt-in to 4 decimal places by setting an optional parameter when initializing an application:


```ruby
client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY,
                                         YOUR_OAUTH_CONSUMER_SECRET,
                                         :unitdp => 4)
```

This option adds the unitdp=4 query string parameter to all requests for models with line items - invoices, credit notes, bank transactions and receipts.

Tests
-----

The tests within the repository can be run by setting up a [Private App](https://developer.xero.com/documentation/auth-and-limits/private-applications).  You can create a Private App in the [developer portal](https://developer.xero.com/myapps/), it's suggested that you create it against the [Demo Company](https://developer.xero.com/documentation/getting-started/development-accounts) (note: the Demo Company expires after 28 days, so you will need to reset it and create a new Private App if you Demo Company has expired).

Once you have created your Private App, set these environment variables:
```
EXPORT CONSUMER_KEY="your private app's consumer key"
EXPORT CONSUMER_SECRET="your private app's consumer secret"
EXPORT PRIVATE_KEY_PATH="the path to your private app's private key"
```

PRIVATE_KEY_PATH is the path to the private key for your Private App (you uploaded the Public Key when you created the Private App)

Then run the tests
```
rake test
```


### Contributors
Xeroizer was inspired by the https://github.com/tlconnor/xero_gateway gem created by Tim Connor 
and Nik Wakelin and portions of the networking and authentication code are based completely off 
this project. Copyright for these components remains held in the name of Tim Connor.
