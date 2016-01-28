module Mollie
  module ResellerAPI
    module Resource
      class BankAccounts < Base
        def getResourceObject
          Mollie::ResellerAPI::Object::BankAccount
        end

        def edit(partner_id_customer, data = {})
          post 'bankaccount-edit', data.merge(:partner_id_customer => partner_id_customer)
        end

        def all(partner_id_customer, data = {})
          post_multiple 'bankaccounts', data.merge(:partner_id_customer => partner_id_customer)
        end
      end
    end
  end
end
