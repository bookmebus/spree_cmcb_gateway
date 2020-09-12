class Cmcb::ClientRedirect
  # options = host:, merchant_id:, secret_key:, callback_url:, payment:
  def initialize(payment)
    @payment = payment
  end

  def self.supported_currencies
    ['usd', 'khr']
  end

  def host
    @payment.payment_method.preferences[:gateway_host]
  end

  def merchant_id
    @payment.payment_method.preferences[:merchant_id]
  end

  def secret_key
    @payment.payment_method.preferences[:secret_key]
  end

  def callback_url
    @payment.payment_method.preferences[:callback]
  end

  def transaction_fee_fix
    @payment.payment_method.preferences[:transaction_fee_fix].to_f
  end

  def transaction_fee_percentage
    @payment.payment_method.preferences[:transaction_fee_percentage].to_f
  end

  def transaction_fee
    transaction_fee_fix + (@payment.amount * transaction_fee_percentage ) / 100
  end

  def amount
    "%.2f" % ( @payment.amount + transaction_fee )
  end

  def transaction_id
    @payment.number
  end

  def currency_code
    'usd'
  end

  def endpoint
    "#{host}/gateway?callback=#{CGI.escape(callback_url)}"
  end

  def request_params
    cipher = "#{amount}#{currency_code}#{merchant_id}#{transaction_id}#{secret_key}"
    hash   = generate_hash(cipher)
    {
      merchantId: merchant_id,
      trxId: transaction_id,
      amount: amount,
      currency: currency_code,
      hash: hash
    }
  end

  def generate_hash(cipher)
    sha256 = Digest::SHA256.hexdigest(cipher)
    Base64.encode64(sha256).strip!
  end

end
