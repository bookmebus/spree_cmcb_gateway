module Spree
  module CmcbGatewayCheckout
    def update
      p "*" * 80
      if payment_params_valid? && cmcb_payment_method?
        p "cmcb_payment_method----------------------------"
        process_with_cmcb_gateway
      else
        p "original ---------------------------------------"
        super
      end
    end

    private
    def process_with_cmcb_gateway
      updated = @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)

      if updated
        byebug
        
        payment = @order.payments.last
        payment.process!
        @client_redirect = ::Cmcb::ClientRedirect.new(payment)
       
        render 'spree/checkout/payment/cmcb_redirect', layout: 'spree/layouts/payment_redirect'
      else
        render :edit
      end
    end
  end

  module CheckoutControllerDecorator
    p "add CheckoutControllerDecorator"

    def payment_method_id_param
      params[:order][:payments_attributes].first[:payment_method_id]
    end

    def cmcb_payment_method?
      payment_method = PaymentMethod.find(payment_method_id_param)
      payment_method.type == 'Spree::Gateway::CmcbGateway'
    end

    def payment_params_valid?
      (params[:state] === 'payment') && params[:order][:payments_attributes]
    end
  end

  CheckoutController.prepend(CmcbGatewayCheckout)
  CheckoutController.prepend(CheckoutControllerDecorator)
end

