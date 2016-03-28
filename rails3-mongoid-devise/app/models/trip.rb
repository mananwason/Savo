class Trip
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user,   inverse_of: :trips

  field :budget_to_beat,      :type => Integer, :default => 0

  field :name, :type => String
  validates_presence_of :name

  field :trip_status, :type => String, :default => "upcoming"

  ## Travel
  field :travel_type, :type => String, :default => "round_trip" #one_way
  field :city_from,              :type => String, :default => ""
  field :city_to,              :type => String, :default => ""
  field :leave_date,              :type => Date, :default => Date.today
  field :return_date,              :type => Date, :default => Date.today
  field :travel_cost,      :type => Integer, :default => 0

  ## Travel
  field :hotel_name, :type => String, :default => ""
  field :hotel_category,              :type => String, :default => "4_star"
  field :hotel_city,              :type => String, :default => ""
  field :check_in,              :type => DateTime, :default => DateTime.now
  field :check_out,              :type => DateTime, :default => DateTime.now
  field :hotel_cost,      :type => Integer, :default => 0

  ## Car
  field :vehicle_name,              :type => String, :default => ""
  field :pick_up_location,              :type => String, :default => ""
  field :pick_up,              :type => DateTime, :default => DateTime.now
  field :drop,              :type => DateTime, :default => DateTime.now
  field :car_cost,      :type => Integer, :default => 0

end
