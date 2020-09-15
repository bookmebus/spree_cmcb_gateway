FactoryBot.define do
  factory :cmcb_payment, class: Spree::Payment do
    amount { 29.99 }
    association(:payment_method, factory: :cmcb_gateway)
    association(:source, factory: :cmcb_payment_source)
    order
    state { 'checkout' }
  end
end
