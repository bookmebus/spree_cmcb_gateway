require 'spec_helper'

RSpec.describe Spree::Gateway::CmcbGateway, type: :model do
  let(:payment_state) { :payment }
  let(:gateway) { create(:cmcb_gateway, auto_capture: true) }
  let(:payment_source) { create(:cmcb_payment_source, payment_method: gateway) }

  let(:order) { OrderWalkthrough.up_to( payment_state) }
  let(:payment) { create(:cmcb_payment, payment_method: gateway, source: payment_source, order: order) }

  describe '#process' do

    it "transform payment state from checkout to processing" do
      checkout = payment.state

      expect(checkout).to eq('checkout')
      payment.process!
      expect(payment.state).to eq('processing')
    end
  end
end
