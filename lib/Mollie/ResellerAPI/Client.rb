require "rest_client"
require 'nokogiri'

["Exception",
"Client/Version",
"Resource/Base",
"Resource/Accounts",
"Resource/BankAccounts",
"Resource/Profiles",
"Object/Base",
"Object/List",
"Object/Account",
"Object/BankAccount",
"Object/Profile"].each {|file| require File.expand_path file, File.dirname(__FILE__) }

module Mollie
  module ResellerAPI
    class Client
      API_LOCATION   = "https://www.mollie.com"
      API_ENDPOINT   = "/api/reseller"
      API_VERSION    = "v1"

      attr_reader :accounts, :profiles, :bank_accounts

      def initialize
        @accounts         = Mollie::ResellerAPI::Resource::Accounts.new self
        @profiles         = Mollie::ResellerAPI::Resource::Profiles.new self
        @bank_accounts    = Mollie::ResellerAPI::Resource::BankAccounts.new self

        @api_location    = API_LOCATION
        @api_endpoint    = API_ENDPOINT
        @api_key         = ""
        @partner_id      = ""
        @profile_key     = ""
        @profile_secret  = ""
        @version_strings = []

        addVersionString "Mollie/" << CLIENT_VERSION
        addVersionString "Ruby/" << RUBY_VERSION
        addVersionString OpenSSL::OPENSSL_VERSION.split(" ").slice(0, 2).join "/"
      end

      def setApiLocation(api_location)
        @api_location = api_location.chomp "/"
      end

      def setApiEndpoint(api_endpoint)
        @api_endpoint = api_endpoint.chomp "/"
      end

      def getApiLocation
        @api_location
      end

      def getApiEndpoint
        @api_endpoint
      end

      def setApiKey(api_key)
        @api_key = api_key
      end

      def setPartnerId(partner_id)
        @partner_id = partner_id
      end

      def setProfileKey(profile_key)
        @profile_key = profile_key
      end

      def setProfileSecret(profile_secret)
        @profile_secret = profile_secret
      end

      def addVersionString(version_string)
        @version_strings << (version_string.gsub /\s+/, "-")
      end

      def _getRestClient(request_url, request_headers)
        RestClient::Resource.new request_url,
          :headers     => request_headers,
          :ssl_ca_file => (File.expand_path "cacert.pem", File.dirname(__FILE__)),
          :verify_ssl  => OpenSSL::SSL::VERIFY_PEER
      end

      def performHttpCall(http_method, api_method, id = nil, http_body = nil)
        request_headers = {
          :accept => :xml,
          :authorization => "Bearer #{@api_key}",
          :user_agent => @version_strings.join(" "),
          "X-Mollie-Reseller-Client-Info" => getUname
        }

        http_body.delete_if { |k, v| v.nil? }
        http_body[:partner_id]  = @partner_id
        http_body[:profile_key] = @profile_key
        http_body[:timestamp]   = Time.now.to_i

        http_code = nil
        begin
          request_path = "#{@api_endpoint}/#{API_VERSION}/#{api_method}/#{id}".chomp "/"
          rest_client = _getRestClient "#{@api_location}#{request_path}", request_headers
          http_body[:signature] = request_signature request_path, http_body

          case http_method
          when "GET"
            xml_response = rest_client.get
          when "POST"
            xml_response = rest_client.post http_body
          when "DELETE"
            xml_response = rest_client.delete
          end
          response = xml_to_hash xml_response
        rescue RestClient::ExceptionWithResponse => e
          http_code = e.http_code
          response = xml_to_hash e.response
          raise e if response[:success].nil?
        end

        unless response[:success]
          exception = Mollie::ResellerAPI::Exception.new response[:resultmessage]
          exception.http_code = http_code
          exception.result_code = response[:resultcode]
          raise exception
        end

        response
      end

      def getUname
        `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
      rescue Errno::ENOMEM
        "uname lookup failed"
      end

      def request_signature(request_path, http_body)
        s = "#{request_path}?" + http_body.sort.map{|k, v| "#{CGI::escape k.to_s}=#{CGI::escape v.to_s}"}.join('&')
        OpenSSL::HMAC.hexdigest OpenSSL::Digest.new("sha1"), @profile_secret, s
      end

      def xml_to_hash(xml)
        doc = xml.is_a?(String) ? Nokogiri::XML(xml) : xml
        response = {}
        parent = doc.respond_to?(:root) ? doc.root : doc
        parent.children.select(&:element?).each do |child|
          response[child.name.intern] =
            if child.name == "success"
              child.text == "true"
            elsif child.name == "items"
              child.children.select(&:element?).map do |item|
                xml_to_hash item
              end
            elsif child.children.select(&:element?).length > 0
              xml_to_hash child
            else
              child.text == "false" ? false : child.text == "true" ? true : child.text
            end
        end
        response
      end
    end
  end
end
