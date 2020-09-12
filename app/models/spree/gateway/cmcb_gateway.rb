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
      byebug
      p "-" * 80
      p "purchase"
      Rails.logger.debug{"About to create payment for order #{gateway_options[:order_id]}"}

      begin
        p "-" * 80
        p gateway_options
        # First of all, invalidate all previous Mollie orders to prevent multiple paid orders
        # Create a new Mollie order and update the payment source
        # source.save!
        ActiveMerchant::Billing::Response.new(true, 'Order created')
      end
    end

    # def purchase(amount, transaction_details, options = {})
    #   byebug
    #   p "-" * 80
    #   p "purchase"
    #   ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
    # end
  
    def authorize(*_args)
      p "-" * 80
      p "authorize"
      ActiveMerchant::Billing::Response.new(true, 'The gateway will automatically capture the amount after creating a shipment.')
    end

    def capture(*_args)
      p "-" * 80
      p "capture"
      ActiveMerchant::Billing::Response.new(true, 'The gateway will automatically capture the amount after creating a shipment.')
    end
  end
end
