require 'rubygems'
require 'hmac-sha1'
require 'base64'
require 'logger'

module Crazylegs

  # Used to create OAuth-signed URLs that you can then request via other means.
  class SignedURL

    READ_ONLY_PARAMS = {
      'oauth_consumer_key' => true,
      'oauth_token' => true,
      'oauth_signature_method' => true,
      'oauth_version' => true,
      'oauth_nonce' => true,
      'oauth_timestamp' => true,
    }

    # Encodes each part of this url, accounting for some
    # of the weirdness we are dealing with
    def self.encodeParts(url)
      parts = url.split(/\//).map do |part|
        if part =~ /^\$/
          part
        else
          encode(part)
        end
      end
      parts.join('/')
    end

    # Ruby's CGI::encode doesn't encode spaces correctly
    def self.encode(string)
      string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end.gsub(' ', '%20')
    end

    # Modify the logger
    attr_accessor :logger

    # Create a new SignedURL
    #
    # +credentails+:: The Credentials available when signing the request
    # +url+:: String containing the URL (without parameters) to request
    # +method+:: The HTTP Request method that will be made, as a String
    # +logger+:: a logger where you'd like to see diagnostics, if omitted will try <tt>$logger</tt> and then create one
    def initialize(credentials,url,method,logger=nil)
      raise ArgumentError.new("credentials is required") if credentials.nil?
      raise ArgumentError.new("url is required") if url.nil?
      raise ArgumentError.new("method is required") if method.nil?

      @credentials = credentials

      @logger = logger || $logger || Logger.new(STDOUT)

      @params = {
        'oauth_signature_method' => 'HMAC-SHA1',
        'oauth_version' => '1.0',
      }
      @params['oauth_consumer_key'] = credentials.consumer_key
      @params['oauth_token'] = credentials.access_token.token if credentials.access_token
      @consumer_secret = credentials.consumer_secret
      if credentials.access_token
        @access_secret = credentials.access_token.secret 
      else
        @access_secret = nil
      end
      @method = method.upcase
      @url = url
    end

    # Sets a request parameter
    #
    # +param+:: the name of the parameter, as a string or symbol
    # +value+:: the value of the parameter, unencoded
    #
    def []=(param,value)
      raise ArgumentError.new("param may not be nil") if param.nil?
      param = param.to_s
      raise ArgumentError.new("You may not override #{param}") if READ_ONLY_PARAMS[param]
      if value.nil? 
        @params.delete(param)
      else
        @params[param] = value.to_s
      end
    end

    # Sets all request parameters to those in the hash.
    #
    # +params_hash+:: hash of all the parameters you want to add; will replace existing parameters
    def params=(params_hash)
      raise ArgumentError.new('you may not set params to nil') if params_hash.nil?
      params_hash.each do |k,v|
        self[k]=v
      end
    end

    # Gets the full URL, signed and ready to be requested
    # +timestamp::+ the timestamp to use; defaults to 'now' and generally is only visible for testing
    # +nonce+ the nonce to use; defaults to a reasonable value and generally is only visible for testing
    #
    # Returns a String that is the entire encoded OAuth-compliant URL ready to be requested.  Note that
    # part of the OAuth signing process is to include the HTTP request method; if you request this url
    # using a method other than the one you passed to the constructor, it will not work.
    def full_url(timestamp=nil,nonce=nil)

      @logger.debug("Getting full_url of #{@url}")
      @logger.debug("OAuth Part 1 : #{@method}")

      escaped_url = SignedURL::encode(@url)
      to_sign = @method + "&" + escaped_url + "&"

      @logger.debug("OAuth Part 2 (raw) : #{@url}")
      @logger.debug("OAuth Part 2 (esc) : #{escaped_url}")

      timestamp=Time.now.to_i if timestamp.nil?
      nonce=@credentials.nonce if nonce.nil?

      param_part,url_params = handle_params(timestamp,nonce)
      escaped_params = SignedURL::encode(param_part)
      @logger.debug("OAuth Part 3 (raw) : #{param_part}")
      @logger.debug("OAuth Part 3 (esc) : #{escaped_params}")

      to_sign += escaped_params

      signature = get_signature(to_sign)

      url_params['oauth_signature'] = SignedURL::encode(signature)

      assembled_url = assemble_url(url_params)
      @logger.debug("Full URL is " + assembled_url)
      return assembled_url
    end

    private

    def assemble_url(url_params)
      url = @url + '?'
      url_params.keys.sort.each do |key|
        val = url_params[key]
        url += "#{key}=#{val}&"
      end
      url.gsub!(/\&$/,'')
      return url
    end

    def get_signature(to_sign)
      signing_key = get_signing_key
      @logger.debug("Signing '#{to_sign}' with key '#{signing_key}'")

      sha1 = HMAC::SHA1.new(signing_key)
      sha1 << to_sign
      signature = Base64.encode64(sha1.digest())
      signature.chomp!
      @logger.debug("signature == '#{signature}'")
      signature
    end

    def get_signing_key
      SignedURL::encode(@consumer_secret) + "&" + SignedURL::encode(@access_secret.nil? ? "" : @access_secret)
    end

    def handle_params(timestamp,nonce)
      url_params = Hash.new
      param_part = ""
      params = @params
      params['oauth_timestamp'] = timestamp.to_s
      params['oauth_nonce'] = nonce
      params.keys.sort.each do |key|
        value = params[key]
        raise ArgumentError.new("#{key} is nil; don't set params to be nil") if value.nil?
        
        @logger.debug("Adding param #{key} with value #{value} escaped as #{SignedURL::encode(value)}")
        param_part += SignedURL::encode(key)
        param_part += "="
        param_part += SignedURL::encode(value)
        param_part += '&'
        url_params[key] = SignedURL::encode(value)
      end
      param_part.gsub!(/&$/,'')
      [param_part,url_params]
    end
  end
end
