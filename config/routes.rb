Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resource :b1_requests do
          collection do
            get 'by_order_number'
            get 'by_all'
            get 'change_need_documenting'

            get 'revert_so_incomingpayment'

            get 'deliver_and_invoice_by_order_number'
            get 'deliver_and_invoice_by_all'

          end
        end
      end
    end
  end
end
