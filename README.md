Xeroizer API Library
====================

**Homepage**: 		[http://github.com/kondro/xeroizer](http://github.com/kondro/xeroizer)	
**Git**: 					[https://github.com/kondro/xero_gateway.git](https://github.com/kondro/xero_gateway.git)	
**Author**: 			Wayne Robinson	
**Contributors**: See Contributors section below	
**Copyright**:    2007-2010		
**License**:      MIT License		

Introduction
------------

This library is designed to help ruby/rails based applications communicate with the publicly available API for Xero.

If you are unfamiliar with the Xero API, you should first read the documentation located at http://developer.xero.com.

Basic Usage
-----------

	require 'xeroizer'
	
	# Create client (used to communicate with the API).
	client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)
	
	# Retrieve list of contacts (note: all communication must be made through the client).
	contacts = client.Contact.all(:order => 'Name')
	
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

Authentication occcurs in 3 steps:

	client = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)
	
	# 1. Get a RequestToken from Xero. The :oauth_url is the URL the user will be redirected to
	#    after they have authenticated your application.
	#
	#    Note: The callback URL's domain must match that listed for your application in http://api.xero.com
	#          otherwise the user will not be redirected and only be shown the authentication code.
	request_token = client.request_token(:oauth_url => 'http://yourapp.com/oauth/callback')
	
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
	
You can now use the client to access the Xero API methods, e.g.

	contacts = client.Contact.all
	
#### Example Rails Controller

	class XeroSessionController < ApplicationController
	
		before_filter :get_xero_client
		
		public
		
			def new
				request_token = @xero_client.request_token(:oauth_url => 'http://yourapp.com/xero_session/create')
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
						:access_key => @xero_client.access_token.key }
																
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
	
#### Storing AccessToken 

You can store the access token/secret pair so you can access the API again without user intervention. Currently these
tokens are only valid for 30 minutes and will raise a `Xeroizer::OAuth::TokenExpired` exception if you try to access
the API beyond the token's expiry time.

If you want API access for longer consider creating a PartnerApplication which will allow you to renew tokens.

	access_key = client.access_token.token
	access_secret = client.access_token.secret

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

	client = Xeroizer::PrivateApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET, "/path/to/privatekey.pem")
	contacts = client.Contact.all

### Partner Applications

Partner applications use a combination of 3-legged authorisation, private key message signing and client-side SSL
certificate signing.

Partner applications are only in beta testing via the Xero API and you will need to contact Xero (network@xero.com) to 
get permission to create a partner application and for them to send you information on obtaining your client-side SSL
certificate.

Ruby's OpenSSL library rqeuires the certificate and private key to be extracted from the `entrust-client.p12` file
downloaded via Xero's instructions. To extract:

	openssl pkcs12 -in entrust-client.p12 -clcerts -nokeys -out entrust-cert.pem
	openssl pkcs12 -in entrust-client.p12 -nocerts -out entrust-private.pem
	openssl rsa -in entrust-private.pem -out entrust-private-nopass.pem
	
	# This last step removes the password that you added to the private key
	# when it was exported.

After you have followed the instructions provided by Xero for partner applications and uploaded your certificate you can
access the partner application in a similar way to public applications.

Authentication occcurs in 3 steps:

	client = Xeroizer::PartnerApplication.new(
						YOUR_OAUTH_CONSUMER_KEY,
						YOUR_OAUTH_CONSUMER_SECRET, 
						"/path/to/privatekey.pem",
						"/path/to/entrust-cert.pem",
						"/path/to/entrust-private-nopass.pem",
						ENTRUST_PRIVATE_KEY_PASSWORD
						)
	
	# 1. Get a RequestToken from Xero. The :oauth_url is the URL the user will be redirected to
	#    after they have authenticated your application.
	#
	#    Note: The callback URL's domain must match that listed for your application in http://api.xero.com
	#          otherwise the user will not be redirected and only be shown the authentication code.
	request_token = client.request_token(:oauth_url => 'http://yourapp.com/oauth/callback')
	
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

This AccessToken will last for 30 minutes however, when using the partner application API you can
renew this token. To be able to renew this token, you need to save the following data from this organisation's
AccessToken:

	session_handle = client.session_handle
	access_key = client.access_token.token
	access_secret = client.access_token.secret
	
Two other interesting attributes of the PartnerApplication client are:

> **`#expires_at`**:								Time this AccessToken will expire (usually 30 minutes into the future).		
> **`#authorization_expires_at`**:	How long this organisation has authorised you to access their data (usually 365 days into the future).		

#### AccessToken Renewal

Renewal of an access token requires knowledge of the previous access token generated for this organisation. To renew:

	# If you still have a client instance.
	client.renew_access_token
	
	# If you are renewing from stored token/session details.
	client.renew_access_token(access_key, access_secret, session_handle)
	
This will invalidate the previous token and refresh the `access_key` and `access_secret` as specified in the
initial authorisation process. You must always know the previous token's details to renew access to this
session.

If you lose these details at any stage you can always reauthorise by redirecting the user back to the Xero OAuth gateway.

Retrieving Data
---------------

Each of the below record types is implemented within this library. To allow for multiple access tokens to be used at the same
time in a single application, the model classes are accessed from the instance of PublicApplication, PrivateApplication
or PartnerApplication. All class-level operations occur on this singleton. For example:

	xero = Xeroizer::PublicApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)
	xero.authorize_from_access(session[:xero_auth][:access_token], session[:xero_auth][:access_key])
	
	contacts = xero.Contact.all(:order => 'Name')
	
	new_contact = xero.Contact.build(:name => 'ABC Development')
	saved = new_contact.save

### \#all(options = {})

Retrieves list of all records with matching options. 

**Note:** Some records (Invoice, CreditNote) only return summary information for the contact and no line items
when returning them this list operation. This library takes care of automatically retrieving the 
contact and line items from Xero on first access however, this first access has a large performance penalty
and will count as an extra query towards your 1,000/day and 60/minute request per organisation limit.

Valid options are:

> **:modified\_since**

> Records modified after this `Time` (must be specified in UTC).

> **:order**

> Field to order by. Should be formatted as Xero-based field (e.g. 'Name', 'ContactID', etc)

> **:where**

> Xero allows advanced custom filters to be added to a request. The where parameter can reference any XML element
> in the resulting response, including all nested XML elements.
> 
> **Example 1: Retrieve all invoices for a specific contact ID:**
> 
> 		invoices = xero.Invoice.all(:where => 'Contact.ContactID.ToString()=="cd09aa49-134d-40fb-a52b-b63c6a91d712"')
> 	
> **Example 2: Retrieve all unpaid ACCREC Invoices against a particular Contact Name:**
> 	
> 		invoices = xero.Invoice.all(:where => 'Contact.Name=="Basket Case" && Type=="ACCREC" && AmountDue<>0')
> 	
> **Example 3: Retrieve all Invoices PAID between certain dates**
> 	
> 		invoices = xero.Invoice.all(:where => 'FullyPaidOnDate>=DateTime.Parse("2010-01-01T00:00:00")&&FullyPaidOnDate<=DateTime.Parse("2010-01-08T00:00:00")')
> 	
> **Example 4: Retrieve all Bank Accounts:**
> 	
> 		accounts = xero.Account.all(:where => 'Type=="BANK"')
> 	
> **Example 5: Retrieve all DELETED or VOIDED Invoices:**
> 	
> 		invoices = xero.Invoice.all(:where => 'Status=="VOIDED" OR Status=="DELETED"')
> 	
> **Example 6: Retrieve all contacts with specific text in the contact name:**
> 
> 		contacts = xero.Contact.all(:where => 'Name.Contains("Peter")')
> 		contacts = xero.Contact.all(:where => 'Name.StartsWith("Pet")')
> 		contacts = xero.Contact.all(:where => 'Name.EndsWith("er")')

### \#first(options = {})

This is a shortcut method for `all` and actually runs all however, this method only returns the
first entry returned by all and never an array.

### \#find(id)

Looks up a single record matching `id`. This ID can either be the internal GUID Xero uses for the record
or, in the case of Invoice, CreditNote and Contact records, your own custom reference number used when
creating these records.

Associations
------------

Records may be associated with each other via two different methods, `has_many` and `belongs_to`.

**has\_many example:**

	invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
	invoice.line_items.each do | line_item |
		puts "Line Description: #{line_item.description}"
	end
	
**belongs\_to example:**

	invoice = xero.Invoice.find('cd09aa49-134d-40fb-a52b-b63c6a91d712')
	puts "Invoice Contact Name: #{invoice.contact.name}"

Creating/Updating Data
----------------------

### Creating

New records can be created like:

	contact = xero.Contact.build(:name => 'Contact Name')
	contact.first_name = 'Joe'
	contact.last_name = 'Bloggs'
	contact.add_address(:type => 'STREET', :line1 => '12 Testing Lane', :city => 'Brisbane')
	contact.add_phone(:type => 'DEFAULT', :area_code => '07', :number => '3033 1234')
	contact.add_phone(:type => 'MOBILE', :number => '0412 123 456')
	contact.save
	
To add to a `has_many` association use the `add_{association}` method. For example:

	contact.add_address(:type => 'STREET', :line1 => '12 Testing Lane', :city => 'Brisbane')
	
To add to a `belongs_to` association use the `build_{association}` method. For example:
	
	invoice.build_contact(:name => 'ABC Company')

### Updating
	
If the primary GUID for the record is present, the library will attempt to update the record instead of
creating it. It is important that this record is downloaded from the Xero API first before attempting
an update. For example:

	contact = xero.Contact.find("cd09aa49-134d-40fb-a52b-b63c6a91d712")
	contact.name = "Another Name Change"
	contact.save
	
Have a look at the models in `lib/xeroizer/models/` to see the valid attributes, associations and 
minimum validation requirements for each of the record types.

### Errors

If a record doesn't match it's internal validation requirements the `#save` method will return
`false` and the `#errors` attribute will be populated with what went wrong.

For example:

	contact = xero.Contact.build
	saved = contact.save
	
	# contact.errors will contain [[:name, "can't be blank"]]
	
\#errors\_for(:attribute\_name) is a helper method to return just the errors associated with
that attribute. For example:

	contact.errors_for(:name) # will contain ["can't be blank"]

If something goes really wrong and the particular validation isn't handled by the internal
validators then the library may raise a `Xeroizer::ApiException`.
