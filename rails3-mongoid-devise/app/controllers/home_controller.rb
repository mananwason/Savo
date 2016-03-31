class HomeController < ApplicationController     

  before_filter :authenticate_user!
  before_filter :index

  require 'httparty'
  require 'json'
  require 'date'

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
  	@user = User.find(current_user.id)
  	@todayDate = Date.parse(Time.now.to_s)
  	@trips = @user.trips
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

    @trips.create({
      name: $trip_name, 
      budget_to_beat: $btb, 
      city_from: $origin_city, 
      city_to: $destination_city, 
      leave_date: DateTime.parse(flightGoing["depTime"]), 
      return_date: DateTime.parse(flightComing["depTime"]), 
      travel_cost: 123
    })

    myTrips
  end 

end

end




