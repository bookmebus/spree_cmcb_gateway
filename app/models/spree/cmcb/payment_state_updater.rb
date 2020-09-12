module Spree
  module Cmcb
    class PaymentStateUpdater
      def initialize(payment, cmcb_trans_status)
        @payment = payment
        @cmcb_trans_status = cmcb_trans_status
      end

      def call
        update_payment_source
        update_order
      end

      private

      def update_payment_source
        source = @payment.payment_source
        if @cmcb_trans_status.paid?
          source.status = 'success'
          source.reference_number = @cmcb_trans_status.reference_number
          source.save
        else
          source.status = 'failed'
          source.reference_number = @cmcb_trans_status.error_message[0...255]
          source.save
        end
      end

      def update_order
        if @cmcb_trans_status.paid?
          transition_to_paid!
        else
          transition_to_failed!
        end
        @payment.order.update_with_updater!
      end

      def transition_to_paid!
        if @payment.completed?
          Rails.logger.debug('Payment is already completed. Not updating the payment status within Spree.')
          return
        end

        # If order is already paid for, don't mark it as complete again.
        @payment.complete!
        Rails.logger.debug('Gateway order has been paid for.')
        complete_order!
      end

      def transition_to_failed!
        @payment.failure! unless @payment.failed?
        @payment.order.update(state: 'payment', completed_at: nil) unless @payment.order.paid_or_authorized?
        Rails.logger.debug("Gateway error check with: #{@cmcb_trans_status.error_message} and will be marked as failed")
      end

      def complete_order!
        return if @payment.order.completed?
        @payment.order.finalize!
        @payment.order.update_attributes(state: 'complete', completed_at: Time.now)
        Rails.logger.debug('Order will be finalized and order confirmation will be sent.')
      end
    end
  end
end
