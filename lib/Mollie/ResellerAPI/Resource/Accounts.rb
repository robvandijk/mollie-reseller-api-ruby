module Mollie
  module ResellerAPI
    module Resource
      class Accounts < Base
        def getResourceObject
          Mollie::ResellerAPI::Object::Account
        end

        def claim(username, password, data = {})
          post 'account-claim', data.merge(:username => username, :password => password)
        end

        def create(data = {})
          post 'account-create', data
        end

        def edit(partner_id_customer, data = {})
          post 'account-edit', data.merge(:partner_id_customer => partner_id_customer)
        end

        def valid(username, password, data = {})
          post 'account-valid', data.merge(:username => username, :password => password)
        end

        def available_payment_methods(partner_id_customer, data = {})
          post 'available-payment-methods', data.merge(:partner_id_customer => partner_id_customer)
        end

        def disconnect(partner_id_customer, data = {})
          post 'disconnect-account', data.merge(:partner_id_customer => partner_id_customer)
        end
      end
    end
  end
end
