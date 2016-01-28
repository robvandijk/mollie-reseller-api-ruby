module Mollie
  module ResellerAPI
    module Resource
      class Base
        def initialize(client)
          @client = client
        end

        def post(api_method, data)
          request("POST", api_method, nil, data) { |response|
            newResourceObject response
          }
        end

        def post_multiple(api_method, data)
          request("POST", api_method, nil, data) { |response|
            Mollie::ResellerAPI::Object::List.new response, getResourceObject
          }
        end

        def newResourceObject(response)
          getResourceObject.new response
        end

        def request(http_method, api_method, id = 0, data)
          response = @client.performHttpCall http_method, api_method, id, data

          yield(response) if block_given?
        end
      end
    end
  end
end
