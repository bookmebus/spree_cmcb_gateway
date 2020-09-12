module SpreeCmcbGateway
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_cmcb_gateway'

    config.autoload_paths += %W[#{config.root}/lib]

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end


    initializer "engine_name.assets.precompile" do |app|
      Rails.application.config.assets.precompile += [
        # 'cmcb_gateway/chipmong-bank-mobile.png', 
        # 'cmcb_gateway/chipmong-bank-wide.jpeg',
        # 'cmcb_gateway/offsite_redirect_submission.js',
        'cmcb_gateway/*',
      ]
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      ::Rails.application.config.spree.payment_methods << Spree::Gateway::CmcbGateway
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
