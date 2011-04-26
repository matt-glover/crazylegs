require 'base64'
require 'openssl'

module Crazylegs

  # Encapsulates a request token, which is what the server returns when
  # you request a user's OAuth Token
  class AccessToken
    attr_reader :token
    attr_reader :secret

    # Create a new token
    # +token+:: the token itself
    # +secret+:: the token secret, used for signing requests
    def initialize(token,secret)
      raise ArgumentError.new('token is required') if token.nil?
      raise ArgumentError.new('secret is required') if secret.nil?
      @token = token
      @secret = secret
    end
  end

  # Encapsulates all the information needed to make a request of the server
  # outside of request-specific information.
  class Credentials
    # Consumer key, provided by the service provider
    attr_reader :consumer_key
    # Consumer secret, provided by the service provider
    attr_reader :consumer_secret
    # Access Token you might have acquired
    attr_reader :access_token
    # The default protocol to use for requests
    attr_reader :default_protocol

    # Create a new Credentials object.
    #
    # +consumer_key+:: The OAuth consumer key given to you when you signed up
    # +consumer_secret+:: The OAuth consumer secret given to you when you signed up
    # +default_protocol+:: Symbol, defaults to <tt>:http</tt>, set this if you must request via <tt>:https</tt>
    # +access_token+:: The access token you were given as a AccessToken, or nil if you don't have one yet.  
    def initialize(consumer_key, consumer_secret, default_protocol=:http, access_token = nil)
      raise ArgumentError.new("consumer_key required") if consumer_key.nil?
      raise ArgumentError.new("consumer_secret required") if consumer_secret.nil?

      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @access_token = access_token
      @default_protocol = default_protocol
    end

    # True if we have an access token
    def has_access_token?
      !@access_token.nil?
    end

    # Update the access token
    def update_access_token(token)
      @access_token = token
      @access_token
    end

    # Clear the access token if, for some reason, you know the one
    # you have is bad.
    def clear_access_token
      update_access_token(nil)
    end

    # Return a nonce that hasn't been used before (at least not in this space/time continuum)
    def nonce
      Time.now.to_f.to_s
    end
  end
end
