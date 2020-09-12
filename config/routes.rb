Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :webhook, path: nil do
    resource :cmcb, only: [] do
      get 'validate/:payment_token', to: 'cmcb#validate'
    end
  end
end
