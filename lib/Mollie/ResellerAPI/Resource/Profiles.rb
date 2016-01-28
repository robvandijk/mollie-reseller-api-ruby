module Mollie
  module ResellerAPI
    module Resource
      class Profiles < Base
        def getResourceObject
          Mollie::ResellerAPI::Object::Profile
        end

        def create(partner_id_customer, data = {})
          post 'profile-create', data.merge(:partner_id_customer => partner_id_customer)
        end

        def all(partner_id_customer, data = {})
          post_multiple 'profiles', data.merge(:partner_id_customer => partner_id_customer)
        end
      end
    end
  end
end
