FactoryBot.define do
  factory :cmcb_gateway, class: Spree::Gateway::CmcbGateway do
    name { 'CMCB Payment Gateway' }
  end
end
