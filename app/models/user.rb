class User < ApplicationRecord
  def self.to_csv
    require 'csv'
    attributes = %w{id email name}
    CSV.generate(headers:  true) do |csv|
      csv << attributes 
      all.each do |user|
        csv << attributes.map{|attr| user.send(attr) }
      end 
    end 
  end 
end
