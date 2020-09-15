module Spree
  module Cmcb
    class PaymentStateUpdater
      def initialize(payment)
        @payment = payment
      end

      def cmcb_trans_status
        @cmcb_trans_status ||= ::Cmcb::TransactionStatus.new(@payment)
      end

      def call
        cmcb_trans_status.call
        update_payment_source
        update_payment_and_order
      end

      private

      def update_payment_source
        source = @payment.payment_source
        if cmcb_trans_status.paid?
          source.status = 'success'
          source.reference_number = cmcb_trans_status.reference_number
          source.save
        else
          source.status = 'failed'
          source.reference_number = cmcb_trans_status.error_message[0...255]
          source.save
        end
      end

      def update_payment_and_order
        if cmcb_trans_status.paid?
          transition_to_paid!
        else
          transition_to_failed!
        end
        
        order_updater
      end

      def order_updater
        @payment.order.update_with_updater!
      end

      def transition_to_paid!
        return if @payment.completed?

        complete_payment!
        complete_order!
      end

      def transition_to_failed!
        @payment.failure! if !@payment.failed?
        @payment.order.update(state: 'payment', completed_at: nil)
        
        notify_failed_payment
      end

      def complete_payment!
        @payment.complete!
      end

      def complete_order!
        return if @payment.order.completed?
        @payment.order.finalize!
        @payment.order.update_attributes(state: 'complete', completed_at: Time.zone.now)
      end

      def notify_failed_payment
        Rails.logger.debug("Gateway error check with: #{cmcb_trans_status.error_message} and will be marked as failed")
      end
    end
  end
end
