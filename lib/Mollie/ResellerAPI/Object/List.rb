module Mollie
  module ResellerAPI
    module Object
      class List < Base
        include Enumerable

        attr_accessor :totalCount,
                      :offset,
                      :count,
                      :items

        def initialize(hash, classResourceObject)
          items        = hash[:items] || []
          hash[:items] = nil
          super hash

          @items = []
          items.each { |hash|
            @items << (classResourceObject.new hash)
          }
        end

        def each(&block)
          @items.each { |object|
            if block_given?
              block.call object
            else
              yield object
            end
          }
        end
      end
    end
  end
end
