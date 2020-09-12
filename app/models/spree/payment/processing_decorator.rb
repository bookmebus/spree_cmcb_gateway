module Spree::Payment::CmcbProcessingDecorator
  def process!
    p "*" * 80
    p "Process in payment"
    byebug

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
    p "process with cmcb gateway"
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

p "-" * 80
p "load processing decorator----------------"
Spree::Payment.include(Spree::Payment::CmcbProcessingDecorator)