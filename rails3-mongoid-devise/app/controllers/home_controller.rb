class HomeController < ApplicationController     

  before_filter :authenticate_user!
  before_filter :index

  require 'httparty'
  require 'json'
  require 'date'

  $car_data = {
      cityName: "Delhi",
      taxiServicesAvailable: [
        {
          compName: "OlaCabs",
          taxiTypes:[
            {
              typeName: "Micro",
              costPerDay: 15.06      
            },
            {
              typeName: "Mini",
              costPerDay: 19.58
            },
            {
              typeName: "Sedan",
              costPerDay: 23
            },
            {
              typeName: "Prime",
              costPerDay: 33     
            }
          ]
        },

        {
          compName: "Uber",
          taxiTypes:[
            {
              typeName: "uberGO",
              costPerDay: 13.06
            },
            {
              typeName: "uberX",
              costPerDay: 15.06
            },
            {
              typeName: "uberBlack",
              costPerDay: 25
            },
            {
              typeName: "uberSUV",
              costPerDay: 37
            }
          ]
        },

        {
          compName: "MeruCabs",
          taxiTypes:[
            {
              typeName: "MeruCab",
              costPerDay: 18
            },
            {
              typeName: "MeruFlexi",
              costPerDay: 25
            }
          ]
        }

      ]
}

  def index
    @users = User.all
    @user = User.find(current_user.id)
    $top_users = User.desc(:points).limit(3)
  end

  def rewards
  	@users = User.all 
  	@user = User.find(current_user.id)
	render "rewards" 
  end

  def convertToNumber(val)
  	if val.nil? || val == ""
  		return 0
  	end
  	return Integer(val)
  end

  def updateRewardPoints
  user = User.find(current_user.id);
	totalPointsRedeemed = convertToNumber(params[:cash]) + convertToNumber(params[:nike])*1000 + convertToNumber(params[:croma])*1000 + convertToNumber(params[:adidas])*1000 + convertToNumber(params[:ebay])*1000 + convertToNumber(params[:sodexo])*1000 + convertToNumber(params[:snapdeal])*1000 + convertToNumber(params[:jabong])*1000
  currentPoints = user.points
	pointsLeft = convertToNumber(currentPoints) - convertToNumber(totalPointsRedeemed) 
	if (pointsLeft) < 0 
		user.points = 0
	else 
		user.points = pointsLeft
	end
  user.save
	rewards     
  end

  def myTrips
  	@user = User.find(current_user.id);
  	@todayDate = Date.parse(Time.now.to_s);
  	@trips = @user.trips;
    @trips.each_index do |i|
      @trips[i]["pick_up_2"] = Date.parse(@trips[i]["pick_up"].to_s).strftime('%a %b %d %Y')
      @trips[i]["drop_2"] = Date.parse(@trips[i]["drop"].to_s).strftime('%a %b %d %Y')
    end
  	render "myTrips"
  end

  def settings 
  	render 'settings'
  end

  def updateSettings
  	user = User.find(current_user.id)
  	name = params[:name]
  	gender = params[:gender]
  	designation = params[:designation]
  	user.update(:name => name)
  	user.update(:gender => gender)
  	user.update(:designation => designation)
  end

  def newTrip
  end 

  def fetchTripBookingDetails

    ##change this id 
  	user = User.find(current_user.id)

    @origin = params["flightFrom"].split("(")[1].split(")")[0]

    @destination = params["flightTo"].split("(")[1].split(")")[0]

  	@result_going = HTTParty.post('http://localhost:8081/api/qpx', 
    :body => {
			  request: {
			    slice: [
			      {
			        origin: params["flightFrom"].split("(")[1].split(")")[0],
			        destination: params["flightTo"].split("(")[1].split(")")[0],
			        date: params["flightLeaveDate"],
			        preferredCabin: 'COACH'
			      }
			    ],
			    passengers: {
			      adultCount: '1',
			      infantInLapCount: '0',
			      infantInSeatCount: '0',
			      childCount: '0',
			      seniorCount: '0'
			    },
			    solutions: '10',
			    maxPrice: 'USD200000.00',
			    refundable: false
			  }
			}.to_json,
    :headers => { 'Accept' => 'application/json', 'Content-Type' => 'application/json' })

    @result_coming = HTTParty.post('http://localhost:8081/api/qpx', 
    :body => {
			  request: {
			    slice: [
			      {
			        origin: params["flightTo"].split("(")[1].split(")")[0],
			        destination: params["flightFrom"].split("(")[1].split(")")[0],
			        date: params["flightLeaveDate"],
			        preferredCabin: 'COACH'
			      }
			    ],
			    passengers: {
			      adultCount: '1',
			      infantInLapCount: '0',
			      infantInSeatCount: '0',
			      childCount: '0',
			      seniorCount: '0'
			    },
			    solutions: '10',
			    maxPrice: 'USD200000.00',
			    refundable: false
			  }
			}.to_json,
    :headers => { 'Accept' => 'application/json', 'Content-Type' => 'application/json' })


    url_hotel = "http://localhost:8081/api/hotels?"
    url_hotel = url_hotel + "city=" + params["accomodationWhere"] + "&checkIn=" + params["accomodationCheckIn"] + "&checkOut=" + params["accomodationCheckOut"] + "&guests=1&rooms=1"

    @hotel_response = HTTParty.get(url_hotel)

    @car_details = $car_data

    # patented algo for budget to beat 
    total = 0
    count = 0
    @result_going["tripOptions"].each do |result|
      begin 
        total += result["cost"].match(/[0-9]+/)[0].to_i
        count += 1
      rescue Exception
        next 
      end
    end

    @budgetToBeat = total.to_f/count.to_f

    ## for next step
    $result_going_global = @result_coming
    $result_coming_global = @result_going
    $trip_name = params['tripName']
    $btb = @budgetToBeat
    $origin_city = params["flightFrom"].split("(")[1].split(")")[0]
    $destination_city = params["flightTo"].split("(")[1].split(")")[0]
    $hotel_data = @hotel_response
    $hotel_where = params["accomodationWhere"]
    $hotel_checkin = params["accomodationCheckIn"]
    $hotel_checkout = params["accomodationCheckOut"]
    $car_pick_up_location = params["carPickUp"]
    $car_pick_up = params["carPickUpDateAndTime"]
    $car_drop = params["carDropOffDateAndTime"]

    @result_coming["tripOptions"].each_index do |i|
      @result_coming["tripOptions"][i]["depTime"] =  DateTime.parse(@result_coming["tripOptions"][i]["depTime"]).strftime("%A, %d %b %Y %l:%M %p")
      @result_coming["tripOptions"][i]["arrTime"] =  DateTime.parse(@result_coming["tripOptions"][i]["arrTime"]).strftime("%A, %d %b %Y %l:%M %p")
      @result_coming["tripOptions"][i]["duration"] = @result_coming["tripOptions"][i]["duration"]/60 

    end

    @result_going["tripOptions"].each_index do |i|
      @result_going["tripOptions"][i]["depTime"] =  DateTime.parse(@result_going["tripOptions"][i]["depTime"]).strftime("%A, %d %b %Y %l:%M %p")
      @result_going["tripOptions"][i]["arrTime"] =  DateTime.parse(@result_going["tripOptions"][i]["arrTime"]).strftime("%A, %d %b %Y %l:%M %p")
      @result_going["tripOptions"][i]["duration"] = @result_going["tripOptions"][i]["duration"]/60
    end

  	render "fetchTripBookingDetails"

  def storeTripDetails
    @user = User.find(current_user.id);
    @trips = @user.trips;

    flightGoing = $result_going_global["tripOptions"][params[:flightGoing].to_i]
    flightComing = $result_coming_global["tripOptions"][params[:flightComing].to_i]
    hotel = $hotel_data["hotels"][params[:hotel].to_i]
    temp = params[:car]
    temp1 = temp.split(" ")[0].to_i
    temp2 = temp.split(" ")[1].to_i

    carDetails = $car_data[:taxiServicesAvailable][temp1][:taxiTypes][temp2]

    date = 
  formatted_date = date

    @trips.create({
      name: $trip_name, 
      budget_to_beat: $btb, 
      city_from: $origin_city, 
      city_to: $destination_city, 
      leave_date: DateTime.parse(flightGoing["depTime"]), 
      return_date: DateTime.parse(flightComing["depTime"]), 
      travel_cost: 123, 
      hotel_name: hotel["name"], 
      hotel_city: $hotel_where, 
      check_in: $hotel_checkin, 
      check_out: $hotel_checkout, 
      hotel_cost: hotel["price"], 
      hotel_category: hotel["rating"].to_i,
      vehicle_name: $car_data[:taxiServicesAvailable][temp1][:compName] + " " + carDetails[:typeName], 
      pick_up_location: $car_pick_up_location, 
      pick_up: DateTime.parse($car_pick_up).strftime('%a %b %d %Y %H:%M'),
      drop: DateTime.parse($car_drop).strftime('%a %b %d %Y %H:%M'), 
      car_cost: carDetails[:costPerDay].to_i * 60
    })

    redirect_to('/myTrips')
  end 

end

end




