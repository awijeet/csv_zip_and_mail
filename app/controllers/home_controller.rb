class HomeController < ApplicationController
  require 'open-uri'
  require 'zip'
  def index    
    option = params[:option]
    options = ["first_fifty", "last_fifty"]
    respond_to do |format|
      format.html do
        current_time = Time.now.to_i.to_s
        FileUtils.mkdir_p "tmp/#{current_time}"        
        ["first_fifty", "last_fifty"].each do |option|
          file_name = Rails.root.join("tmp/#{current_time}", "#{rand(1...999999)}.csv")
          open(file_name, 'wb') do |file|
            file << URI.open("http://localhost:3000/home/index.csv?option=#{option}").read 
          end  
        end       
        Zip::File.open( "public/#{current_time}.zip", Zip::File::CREATE ) do |zip_file|
          Dir[ File.join( "tmp/#{current_time}", "**", "**" ) ].each do |file|
            zip_file.add( file.sub( "tmp/#{current_time}/", "" ), file ) 
          end
        end 
        FileUtils.rm_rf("#{Rails.root}/tmp/#{current_time}")
        send_file "public/#{current_time}.zip", :x_sendfile=>true 
        # head :ok
      end

      format.csv do  
        @users = User.all              
        if option == "first_fifty"
          @users = User.where("id in (?)", (1..50))
        else
          @users = User.where("id in (?)", (51..99))
        end 
        send_data @users.to_csv, filename: "user_file.csv"
      end 
    end 
  end
end
