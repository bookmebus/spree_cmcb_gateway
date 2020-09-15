require 'spec_helper'

RSpec.describe Spree::Cmcb::PaymentStateUpdater, type: :model do
  let(:payment_state) { :payment }
  let(:gateway) { create(:cmcb_gateway, auto_capture: true) }
  let(:payment_source) { create(:cmcb_payment_source, payment_method: gateway) }

  let(:order) { OrderWalkthrough.up_to( payment_state) }
  let(:payment) { create(:cmcb_payment, payment_method: gateway, source: payment_source, order: order) }

  let(:status_updater) {
    payment.process!
    Spree::Cmcb::PaymentStateUpdater.new(payment)
  }

  describe '#update_payment_source' do
    context 'cmcb_trans_status#paid? is true' do
      it "update payment source status to success and reference_number from cmcb_tran" do
        cmcb_tran = double(:cmcb_trans_status, :paid? => true, reference_number: '123456' )
        allow(status_updater).to receive(:cmcb_trans_status).and_return(cmcb_tran)
        
        status_updater.send(:update_payment_source)
        payment_source.reload

        expect(payment_source.status).to eq 'success'
        expect(payment_source.reference_number).to eq '123456'
      end
    end

    context 'cmcb_trans_status#paid? is not true' do
      it "update payment source status to failed and save reference_number to error_message" do
        cmcb_tran = double(:cmcb_trans_status, :paid? => false, error_message: 'Transaction is not found' )
        allow(status_updater).to receive(:cmcb_trans_status).and_return(cmcb_tran)

        status_updater.send(:update_payment_source)
        payment_source.reload

        expect(payment_source.status).to eq 'failed'
        expect(payment_source.reference_number).to eq 'Transaction is not found'
      end
    end
  end

  describe '#complete_payment!' do
    it 'marks payment state to completed' do
      status_updater.send(:complete_payment!)
      payment.reload

      expect(payment.state).to eq 'completed'
    end
  end
  describe '#complete_order!' do
    it 'updates order state to be complete' do
      status_updater.send(:complete_order!)
      order.reload

      expect(order.state).to eq 'complete'
      expect(order.completed_at).not_to be_nil
    end
  end

  describe '#transition_to_paid!' do
    it 'mark payment and order state to be complete' do
      status_updater.send(:transition_to_paid!)
      payment.reload

      expect(payment.state).to eq 'completed'
      expect(payment.order.state).to eq 'complete'
    end
  end

  describe '#transition_to_failed!' do
    it 'mark payment and order state to be complete' do
      cmcb_tran = double(:cmcb_trans_status, :paid? => false, error_message: 'Transaction is not found' )
      allow(status_updater).to receive(:cmcb_trans_status).and_return(cmcb_tran)

      status_updater.send(:transition_to_failed!)
      payment.reload

      expect(payment.state).to eq 'failed'
      expect(payment.order.state).to eq 'payment'
    end
  end

end
