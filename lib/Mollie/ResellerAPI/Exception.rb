module Mollie
  module ResellerAPI
    class Exception < StandardError
      @result_code = nil
      @http_code = nil

      attr_accessor :result_code, :http_code
    end
  end
end
