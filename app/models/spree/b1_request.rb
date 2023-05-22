module Spree
  class B1Request < Spree::Base
    belongs_to :order


    def make_request_b1
      url = api_address+"/CreateOrder"
      payload = prepare_request_body
      headers = {
        "Content-Type" => "application/json"
      }
      response = HTTParty.post(url, headers: headers, body: payload)
      response_object = JSON.parse(response.body)
      self.response = response_object
      self.request = payload
      self.save
      process_response response_object
    end

    private
    def get_token
      @token ||= request_token
    end
    def process_response response_object
      documenting_result = ActiveSupport::HashWithIndifferentAccess.new
      if response_object["action"] == -1 && response_object["status"] == 4 && response_object["error"].empty?
        result = response_object["result"]
        result.each do |doc|
          case doc["docType"]
          when 17
            documenting_result[:so_doc_entry], documenting_result[:so_doc_num] = doc["docEntry"], doc["docNum"]
          when 24
            documenting_result[:incoming_payment_doc_entry], documenting_result[:incoming_payment_doc_num] = doc["docEntry"], doc["docNum"]
          end
        end
      elsif response_object["action"] == 2 && response_object["status"] == 1 && !response_object["error"].empty?
        result = response_object["result"]
        result.each do |doc|
          case doc["docType"]
          when 17
            documenting_result[:so_doc_entry], documenting_result[:so_doc_num] = doc["docEntry"], doc["docNum"]
          when 24
            documenting_result[:incoming_payment_doc_entry], documenting_result[:incoming_payment_doc_num] = doc["docEntry"], doc["docNum"]
          end
        end
        p "documenting_resultdocumenting_resultdocumenting_resultdocumenting_result"
        puts documenting_result        
      end
      finalize_the_process documenting_result
    end
    def finalize_the_process documenting_result
      self.order.b1_doc_entry = documenting_result[:so_doc_entry]
      self.order.b1_doc_num = documenting_result[:so_doc_num]
      self.order.b1_documented = true
      payment = self.order.payments.completed.last
      payment.b1_doc_entry = documenting_result[:incoming_payment_doc_entry]
      payment.b1_doc_num = documenting_result[:incoming_payment_doc_num]
      payment.b1_documented = true
      self.order.save!
      payment.save!
      self.is_success = true
      self.save!
    end
    def prepare_request_body
      marketing_lines = prepare_marketing_lines_body
      delivery_cost = self.order.has_free_shipping? ? 0 : self.order.shipment_total
      {
          "token": get_token,
          "marketdoc": {
              "CardCode": create_or_get_user_b1_code,
              "marketingapprelatedid": "MiarzeOrder#{self.order.id}",
              "PaymentAppRelatedId": "MiarzePayment#{self.order.payments.completed.last.id}",
              "MarketingLines": marketing_lines,
              "DocTime": self.order.completed_at
              "IncomingLines": [
                  {
                      "Type": 2,
                      "Value": self.order.payments.completed.last.amount.to_f,
                      "DueDateTime": self.order.payments.completed.last.created_at,
                      "Reference": self.order.payments.completed.last.number
                  }
              ],
              "marketingdetails": {
                  "Campaign": 35
              },
              "ExpenseCost":[{
                  "ExpenseCode":1,
                  "GrossCost": delivery_cost.to_f
              }]
          },
          "SettleType": 16,
          "PaymentTime": 5,
          "DeliveryType": 19,
          "PayDueDate": 1
      }.to_json
    end
    def free_shipping?
      self.order.has_free_shipping?
    end
    def request_token
      url = api_address+"/Login"
      payload = {
      "Username"=> "Miarze",
      "Password"=>"Miarze@KhiliKhobeh402"
      }.to_json
      headers = {
        "Content-Type" => "application/json"
      }
      response = HTTParty.post(url, headers: headers, body: payload)
      response.parsed_response
    end
    def prepare_marketing_lines_body
      ml = []
      amounts = self.order.adjustments.pluck(:amount)
      discount_amount = amounts.empty? ? 0 : amounts.first
      discount_percent = discount_amount.to_f / self.order.item_total.to_f 
      order.line_items.each do |item|
        price = item.price == 1 ? item.price : item.price * ( 1 - discount_percent)
        line = {
            "ItemCode": item.variant.sku,
            "ItemQty": item.quantity,
            "Price": price.to_f
              }
        ml.push(line)
      end
      ml
    end
    def create_or_get_user_b1_code
      if self.order.user.b1_code.nil?
        create_user_b1_code
      end
      self.order.user.b1_code
    end
    def create_user_b1_code
      payload = prepare_create_user_b1_code_body
      url = api_address+"/NewEndCustomer"
      headers = {
        "Content-Type" => "application/json"
      }
      response = HTTParty.post(url, headers: headers, body: payload)
      response_object = JSON.parse(response.body)
      self.order.user.b1_code = response_object["customer"]["cardCode"]
      self.order.user.save!
    end
    def prepare_create_user_b1_code_body
      user = self.order.user
      cardname = "#{user.fi_name} #{user.la_name}"
      bpapprelatedid = "MiarzeUser#{user.id}"
      phone1 = user.mobile_number
      cellular = user.mobile_number
      address = user.addresses.last.address1
      city =  user.addresses.last.state.name
      county = "0#{user.addresses.last.country.numcode}"
      idnumber = user.national_id
      lat = "#{user.addresses.last.lat}"
      long = "#{user.addresses.last.lng}"
      zipcode = user.addresses.last.zipcode
      {
        "token"=> get_token,
          "customer" => {
              "cardname" => cardname,
              "bpapprelatedid" => bpapprelatedid ,
              "phone1" => phone1,
              "phone2" => "",
              "cellular" => cellular,
              "address" => address,
              "city" => city,
              "county" => county,
              "idnumber" => idnumber,
              "lat" => lat,
              "long" => long,
              "zipcode" => zipcode
          }

      }.to_json
    end
    def api_address
      "https://b1api.burux.com/api/BRXIntLayer"
    end
  end
end
