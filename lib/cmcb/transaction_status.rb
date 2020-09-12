require 'faraday'

class Cmcb::TransactionStatus
  attr_accessor :response

  def initialize(payment)
    @payment = payment
  end


  def host
    @payment.payment_method.preferences[:gateway_host]
  end

  def transaction_id
    @payment.number
  end

  def json_response
    ActiveSupport::JSON.decode(@response.body)
  end

  # {"data"=>{"status"=>"success", "referenceNumber"=>"552654"}}
  def call
    check(transaction_id)
  end

  def paid?
    json_response['data']['status'] == 'success' rescue false
  end

  def reference_number
    json_response['data']['referenceNumber'] rescue ''
  end

  def error_message
    json_response['error'] rescue @response.body
  end

  def check(trx_id)

    url = "#{host}/api/transactions/#{trx_id}/status"
    @response = Faraday.get(url)

    if @response.status == 200
      # 200: {"data"=>{"status"=>"success", "referenceNumber"=>"552654"}}
      json_response 
    else
      # 404: {"error"=>"Transaction is not found"}
      json_response rescue @response.body
      false
    end
  end
end
