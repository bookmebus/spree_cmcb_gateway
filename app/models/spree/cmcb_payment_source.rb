class Spree::CmcbPaymentSource < Spree::Base
    belongs_to :payment_method
    has_many :payments, as: :source

    # def actions
    #   []
    # end

    # def transaction_id
    #   payment_id
    # end

    def method_type
      'cmcb_payment_source'
    end

    def name
      payment_method_name
    end

end
