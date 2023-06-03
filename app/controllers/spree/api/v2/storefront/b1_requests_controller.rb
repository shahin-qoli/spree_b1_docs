module Spree
	module Api
		module V2
			module Storefront
				class B1RequestsController < ::Spree::Api::V2::ResourceController
					before_action :check_admin_role
					def deliver_and_invoice_by_order_number
						order = Spree::Order.find_by_number(params["order_number"])
						payment = order.payments.completed.last
						if order.b1_doc_entry.nil? || order.b1_doc_entry.nil?
							render :json => {"error" => "This order doesn't have SO or Payment in B1",
								"is_success" => false,
								"order_number" => order.number
							}
						else
							request_delivery = order.b1_requests.create
							if request_delivery.make_request_delivery
								request_invoice = order.b1_requests.create
								request_invoice.make_request_invoice
								render :json => {"error" => "",
								"order_number" => order.number,
								"is_success" => request_invoice.is_success,
								"delivery_b1_doc_number" => order.delivery_b1_doc_number,
								"delivery_b1_doc_entry" => order.delivery_b1_doc_entry,
								"invoice_b1_doc_number" => order.invoice_b1_doc_number,
								"invoice_b1_doc_entry" => order.invoice_b1_doc_entry
								}
							else
								render :json => { "error" => "This order doesn't proccessed, cannot Deliver", "is_success" => false,  "order_number" => order.number}
							end
						end
					end
					def deliver_and_invoice_by_all
						orders = Spree::Order.where(delivery_b1_doc_entry== nil).or(invoice_b1_doc_entry== nil)
						if orders.empty
							render	json: {"error" => "All orders are proccessed already"}
						else
							results = []
							orders.each do |order|
								request = order.b1_request.create
								if request.make_request_delivery
									request_invoice = order.b1_requests.create
									request_invoice.make_request_invoice
									result = {"error" => "",
										"order_number" => order.number,
										"is_success" => request_invoice.is_success,
										"delivery_b1_doc_number" => order.delivery_b1_doc_number,
										"delivery_b1_doc_entry" => order.delivery_b1_doc_entry,
										"invoice_b1_doc_number" => order.invoice_b1_doc_number,
										"invoice_b1_doc_entry" => order.invoice_b1_doc_entry
										}
									results.push(result)
								else
									result = {"error" => "This order doesn't proccessed, cannot Deliver",
										"order_number" => order.number,
										"is_success" => false,
									}
									results.push(result)
								end
							end
							render json: {"count_of_order_proccessed" => order.count,
								"results" => results}
						end
					end
					def by_order_number
						order = Spree::Order.find_by_number(params["order_number"])
						payment = order.payments.&completed.last
						if order.b1_documented || payment.b1_documented 
							payment = order.payments.completed.last
							render :json => {"error" => "This order is proccessed already",
								"is_success" => false,
								"order_number" => order.number,
								"so_b1_doc_number" => order.b1_doc_num,
								"so_b1_doc_entry" => order.b1_doc_entry,
								"incoming_payment_b1_doc_number" => payment.b1_doc_num,
								"incoming_payment_b1_doc_entry" => payment.b1_doc_entry
							}
						elsif !order.need_document
							render :json => { "error" => "This order doesn't need documenting", "is_success" => false,  "order_number" => order.number}
						else 
							request = order.b1_requests.create
							request.make_request_b1
							refresh_payment = order.payments.completed.last
							render :json => {"error" => "",
							"order_number" => order.number,
							"is_success" => request.is_success,
							"so_b1_doc_number" => order.b1_doc_num,
							"so_b1_doc_entry" => order.b1_doc_entry,
							"incoming_payment_b1_doc_number" => refresh_payment.b1_doc_num,
							"incoming_payment_b1_doc_entry" => refresh_payment.b1_doc_entry
							}
						end
					end
					def by_all
						orders = Spree::Order.complete.where.not(b1_documented: true, need_document: false)
						if orders.empty?
							render	json: {"error" => "All orders are proccessed already"}
						else
							results = []
							orders.each do |order|
								request = order.b1_requests.create
								request.make_request_b1
								payment = order.payments.completed.last
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
						if order.b1_documented 
							render :json => {"error" => "This order is proccessed already",
								"order_number" => order.number }
						else		
							order.update(need_document: false)
							render :json => {"error" => "", "result" => "This order won't proccess",
								"order_number" => order.number}
						end
					end
					def revert_so_incomingpayment
						order = Spree::Order.find_by_number(params["order_number"])
						payment = order.payments.&completed.last
						if (order.b1_documented || payment.b1_documented) && order.need_document
							order.update(b1_documented: false)
							payment.update(b1_documented: false)
							return :json => {"result" => "This order is ready to create document again",
								"order_number" => order.number}
						else
							return :json => {"error" => "this order isn't documented or is marked as doesn't need documenting",
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
