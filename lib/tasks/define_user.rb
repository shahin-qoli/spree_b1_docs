require 'httparty'
namespace :users do
  desc "Define new users in B1"
  task :define => :environment do
    data = [
      ['Name', 'Age', 'Email'],
      ['John Doe', 30, 'johndoe22@example.com'],
      ['Jane Smith', 25, 'janesmith22@example.com']
    ]
        # Write data to CSV
    CSV.open('data.csv', 'wb') do |csv|
      data.each do |row|
        csv << row
      end
    end

    puts "Data written to data.csv"
  end
end