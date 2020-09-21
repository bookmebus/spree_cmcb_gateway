FactoryBot.define do
  # Credit card payment
  factory :cmcb_payment_source, class: Spree::CmcbPaymentSource do
    payment_method_name { 'qrcode' }
    status { '' }
    reference_number { '' }
  end
end
