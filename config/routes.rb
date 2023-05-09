Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resource :b1_requests do
          collection do
            get 'by_order_number'
            get 'by_all'
          end
        end
      end
    end
  end
end
