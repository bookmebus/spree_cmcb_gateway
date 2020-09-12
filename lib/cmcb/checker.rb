class Cmcb::Checker
  attr_accessor :response

  def initialize(options)
    @options = options
  end

  # {data: { status: 'success', referenceNumber: 12345}}
  def valid?
    status_checker = Cmcb::TransactionStatus.new(@options[:host])
    @response = status_checker.exec(@options[:transaction_id])

    return @response && @response['data']['status'] == 'success'
  end

end
