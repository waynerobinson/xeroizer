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
	#    Note: The callback URL's domain must match that listed for your application in [http://api.xero.com](http://api.xero.com)
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

You need to upload this public_privatekey.pfx file to your private application in [http://api.xero.com](http://api.xero.com).

Example usage:

	client = Xeroizer::PrivateApplication.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET, "/path/to/privatekey.pem")
	contacts = client.Contact.all

### Partner Applications

Partner applications use a combination of 3-legged authorisation, private key message signing and client-side SSL
certificate signing.

Partner applications are only in beta testing via the Xero API and you will need to contact Xero (network@xero.com) to 
get permission to create a partner application and for them to send you information on obtaining your client-side SSL
certificate.

After you have followed the instructions provided by Xero for partner applications and uploaded your certificate you can
access the partner application in a similar way to public applications.