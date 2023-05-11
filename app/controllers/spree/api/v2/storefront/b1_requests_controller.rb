module Spree
	module Api
		module V2
			module Storefront
				class B1RequestsController < ::Spree::Api::V2::ResourceController
					before_action :check_admin_role
					def by_order_number
						order = Spree::Order.find_by_number(params["order_number"])
						payment = order.payments.completed.last
						if order.b1_documented || payment.b1_documented 
							payment = order.payments.completed.last
							render :json => {"error" => "This order is proccessed already",
								"order_number" => order.number,
								"so_b1_doc_number" => order.b1_doc_num,
								"so_b1_doc_entry" => order.b1_doc_entry,
								"incoming_payment_b1_doc_number" => payment.b1_doc_num,
								"incoming_payment_b1_doc_entry" => payment.b1_doc_entry
							}
						elsif !order.need_document
							render :json => { "error" => "This order doesn't need documenting",  "order_number" => order.number}
						else 
							request = order.b1_requests.create
							request.make_request_b1
							refresh_payment = order.payments.completed.last
							render :json => {"error" => "",
							"order_number" => order.number,
							"so_b1_doc_number" => order.b1_doc_num,
							"so_b1_doc_entry" => order.b1_doc_entry,
							"incoming_payment_b1_doc_number" => refresh_payment.b1_doc_num,
							"incoming_payment_b1_doc_entry" => refresh_payment.b1_doc_entry
							}
						end
					end
					def by_all
						orders = Spree::Order.where(b1_documented != true)
						if orders.empty
							render	json: {"error" => "All orders are proccessed already"}
						else
							results = []
							orders.each do |order|
								request = order.b1_request.create
								request.make_request_b1
								result = {"error" => "",
								"order_number" => order.number,
								"so_b1_doc_number" => order.b1_doc_num,
								"so_b1_doc_entry" => order.b1_doc_entry,
								"incoming_payment_b1_doc_number" => payment.b1_doc_num,
								"incoming_payment_b1_doc_entry" => payment.b1_doc_entry
								}
								results.push(result)
							end
							render json: {"count_of_order_proccessed" => order.count,
								"results" => results}
						end
					end
					def change_need_documenting
						order = Spree::Order.find_by_number(params["order_number"])
						if order.b1_documented || payment.b1_documented 
							render :json => {"error" => "This order is proccessed already",
								"order_number" => order.number }
						else		
							order.update(need_document: false)
							render :json => {"error" => "", "result" => "This order won't proccess",
								"order_number" => order.number}
						end
					end
					private
					def check_admin_role
						user = spree_current_user
						unless user.has_spree_role?('admin')
						  render json: { error: 'Unauthorized' }, status: :unauthorized
						end
					end
				end
			end
		end
	end
end