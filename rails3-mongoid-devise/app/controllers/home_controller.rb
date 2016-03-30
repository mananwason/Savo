class HomeController < ApplicationController     

  before_filter :authenticate_user!
  before_filter :index

  def index
    @users = User.all
    @user = User.find(current_user.id)
    $top_users = User.desc(:points).limit(3)
  end

  def rewards
  	@users = User.all 
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

	totalPointsRedeemed = convertToNumber(params[:cash]) + convertToNumber(params[:nike]) + convertToNumber(params[:croma]) + convertToNumber(params[:adidas]) + convertToNumber(params[:ebay]) + convertToNumber(params[:sodexo]) + convertToNumber(params[:snapdeal]) + convertToNumber(params[:jabong]); 
	currentPoints = user.points
	pointsLeft = convertToNumber(totalPointsRedeemed) - convertToNumber(currentPoints)
	if (pointsLeft) < 0 
		user.update(points: 0)
	else 
		user.update(points: pointsLeft)
	end
	render "rewards"     
  end

  def myTrips
  	@user = User.find(current_user.id);
  	@todayDate = Date.today;
  	@trips = @user.trips;
  	render "myTrips"
  end

end
