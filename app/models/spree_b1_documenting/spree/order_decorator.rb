module SpreeB1Documenting::Spree::OrderDecorator

  def self.prepended(base)
    base.has_many :b1_requests, class_name: 'Spree::B1Request'

  end
end

Spree::Order.prepend SpreeB1Documenting::Spree::OrderDecorator