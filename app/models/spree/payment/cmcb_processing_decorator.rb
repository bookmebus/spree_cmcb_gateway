module Spree::Payment::CmcbProcessingDecorator
  def process!
    if payment_method.is_a? Spree::Gateway::CmcbGateway # Spree::Gateway::CmcbGateway
      process_with_cmcb_gateway
    else
      super
    end
  end

  def cancel!
    if payment_method.is_a? Spree::Gateway::CmcbGateway
      cancel_with_cmcb_gateway
    else
      super
    end
  end

  # private

  def cancel_with_cmcb_gateway
    response = payment_method.cancel(transaction_id)
    handle_response(response, :void, :failure)
  end

  def process_with_cmcb_gateway
    amount ||= money.money
    started_processing!

    response = payment_method.process(
      amount,
      source,
      gateway_options
    )
    handle_response(response, :started_processing, :failure)
  end
end

Spree::Payment.include(Spree::Payment::CmcbProcessingDecorator)