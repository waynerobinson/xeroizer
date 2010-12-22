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
	new_contact.save
