module Spree
  class Gateway::CmcbGateway < PaymentMethod
    preference :gateway_host, :string
    preference :merchant_id, :string
    preference :secret_key, :string
    preference :callback, :string
    preference :transaction_fee_fix, :float, default: 0
    preference :transaction_fee_percentage, :float, default: 0


    has_many :spree_cmcb_payment_sources, class_name: 'Spree::CmcbPaymentSource'

    # When set to true, the gateway will automatically charge all discounts and shipping
    def actions
      %w[credit]
    end

    def method_type
      'cmcb_gateway'
    end

    def payment_source_class
      Spree::CmcbPaymentSource
    end

    # Always create a source which references to the selected Gateway payment method.
    def source_required?
      true
    end

    def available_for_order?(_order)
      true
    end

    def auto_capture?
      # default to: Spree::Config[:auto_capture]
      true
    end

    # Custom PaymentMethod/Gateway can redefine this method to check method
    # availability for concrete order.
    def available_for_order?(_order)
      true
    end

    def available_for_store?(store)
      return true if store.blank? || store_id.blank?
      store_id == store.id
    end

    def process(money, source, gateway_options)
      Rails.logger.debug{"About to create payment for order #{gateway_options[:order_id]}"}
      # First of all, invalidate all previous tranx orders to prevent multiple paid orders
      # source.save!
      ActiveMerchant::Billing::Response.new(true, 'Order created')

    end
  
  end
end
