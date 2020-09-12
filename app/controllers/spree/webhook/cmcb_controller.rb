module Spree
  module Webhook
    class CmcbController < BaseController
      skip_before_action :verify_authenticity_token, only: [:validate]
  

      # GET /cmcb/validate/:payment_token -> /cmcb/validate/PMD4AOT4
      def validate
        payment = Spree::Payment.find_by number: params[:payment_token]

        cmcb_status = ::Cmcb::TransactionStatus.new(payment)
        cmcb_status.call

        order = payment.order
        spree_updater = Spree::Cmcb::PaymentStateUpdater.new(payment, cmcb_status)
        spree_updater.call
        # Cmcb.update_payment_status payment
  
        # Rails.logger.info("Redirect URL visited for order #{params[:order_number]}")
        order = order.reload
  
        # # Order is paid for or authorized (e.g. Klarna Pay Later)
        redirect_to order.paid? || payment.pending? ? order_path(order) : checkout_state_path(:payment)
      end
    end
  
  end
end
