var express = require('express');
var bodyParser = require('body-parser');	
var http = require('http');
var https = require('https');
var querystring = require('querystring');
var geocoderProvider = 'google';
var httpAdapter = 'https';

var extra = {
    //apiKey: 'AIzaSyDAnb-JWBk2cCSWjRQ4G3gAUep-vWKzLtw', // for Mapquest, OpenCage, Google Premier 
    apiKey: 'AIzaSyAzdcxJ-1zlUVRs7STYSWAfp4x6xCjYX24',
    formatter: null         // 'gpx', 'string', ... 
};

var geocoder = require('node-geocoder')(geocoderProvider, httpAdapter, extra);

geocoder.geocode('delhi', function(err, res) {
    console.log(res[0].latitude,res[0].longitude);
});
console.log("dfbdfsbgnbfgngf");
geocoder.reverse({lat:45.767, lon:4.833}, function(err, res) {
    console.log(res[0].formattedAddress);
});

var app = express();
app.use(bodyParser.json())

app.get('/', function (req, res) {
	res.send('Hello World');
})



var options = {
  	host: 'partners.api.skyscanner.net',
  	path: '/apiservices/hotels/liveprices/v2/UK/EUR/en-GB/28.5562,77.1000-latlong/2016-04-04/2016-04-10/2/1?apiKey=prtl6749387986743898559646983194',
  	header: {"Accept":"application/json"},
  	method:"GET"
  	//This is the only line that is new. `headers` is an object with the headers to request
};

callback2 = function(response, getRes) {
	var str = ''
	response.setEncoding('utf8');

	response.on('data', function (chunk) {
		str += chunk;
	});
	response.on('end', function () {
		//console.log(JSON.parse(str));
		console.log("----------------------------------------")
		var x = JSON.parse(str);
		//console.log(x.hotels_prices[0]);
		var hotels=[];
		for(var i=0;i<x.hotels_prices.length;i++){
			var hotelId = x.hotels_prices[i].id;
			var price = x.hotels_prices[i].price_total;
			var images=[];
			//console.log(hotelId);
			var hotel;
			//var hotelObj;
			for(var j=0;j<x.hotels.length;j++){
				if(x.hotels[j].hotel_id==hotelId){
					hotel = x.hotels[j];
					var address;
					
					geocoder.reverse({lat:hotel.latitude, lon:hotel.longitude}, function(err, res) {
						address = res[0].formattedAddress;
					});
					var hotelObj={
						"name": hotel.name,
						"price": x.hotels_prices[i].agent_prices[0].price_total,
						"distance":hotel.distance_from_search,
						"rating":hotel.star_rating,
						"latitude":hotel.latitude,
						"longitude":hotel.longitude,
						"address":"address"
					}
					hotels.push(hotelObj);
					//console.log(hotel.name);
					break;
				}
				//console.log("----------");
			}
			//console.log("*********");
		}
		//console.log(hotels);

		getRes.send({"hotels":hotels});
		/*getRes.writeHead(200, {
	      'Content-Type' : 'x-application/json'
	    });
	    getRes.end(str);*/

	});
}

callback = function(response,getRes) {
	var temp = options;
	temp.path = response.headers.location;
	//var req = http.request(temp, callback2);
	var req = http.request(temp, function(response) {
		callback2(response,getRes);
	  });
	req.end();
}


//sample get request - http://localhost:8081/api/hotels?city=delhi&checkIn=2016-04-01&checkOut=2016-04-04&guests=1&rooms=1
app.get('/api/hotels', function (req, res) {
	//var req = http.request(options, callback);
	//console.log(req.query.latLong);
	//console.log(req.query.checkIn);
	var lat,long;
	var x = req.query;
	console.log(req.query.checkIn);
	geocoder.geocode(req.query.city, function(err, resGeo) {
		console.log(resGeo[0].latitude);
		console.log(x.checkIn);
		var lat = resGeo[0].latitude;
		var long = resGeo[0].longitude;
		var queryPath = "/apiservices/hotels/liveprices/v2/UK/EUR/en-GB/"+lat+","+long+"-latlong/"+x.checkIn+"/"+x.checkOut+"/"+x.guests+"/"+x.rooms+"?apiKey=prtl6749387986743898559646983194";
		options.path = queryPath;
		console.log(queryPath);
		var req = http.request(options, function(response) {
			callback(response,res);
		  });
		req.end();
	});
	
	//res.send({"response":"hello"});
	//res.send();
})

var optionsQpx = {
  	host: 'www.googleapis.com',
  	path: '/qpxExpress/v1/trips/search?key=AIzaSyAzdcxJ-1zlUVRs7STYSWAfp4x6xCjYX24',
  	port: 443,
  	headers: {'Content-Type': 'application/json', 'Accept':'application/json'},
  	method:"POST"
  	//This is the only line that is new. `headers` is an object with the headers to request
};

callbackQpx = function(response,getRes) {
	var str = ''
	response.setEncoding('utf8');

	response.on('data', function (chunk) {
		str += chunk;
	});
	response.on('end', function () {
		jsonObj = JSON.parse(str);
		console.log(JSON.parse(str));
		if(jsonObj.error){
			console.log("****************")
			console.log(jsonObj.error.errors[0]);	
		}
		var tripOptions = [];
		var trips = jsonObj.trips;
		if(trips){
			var data = trips.data;
			var tripOption = trips.tripOption;
			for (var i = 0; i < tripOption.length; i++) {
				var cost = tripOption[i].saleTotal;
				var slice = tripOption[i].slice;	
				var carrierDep = slice[0].segment[0].flight.carrier;
				var depTime = slice[0].segment[0].leg[0].departureTime;
				var carrierArr = slice[0].segment[slice[0].segment.length - 1].flight.carrier;
				var arrTime = slice[0].segment[slice[0].segment.length - 1].leg[0].arrivalTime;	
				var numberOfStops = slice[0].segment.length - 1;
				//console.log("SLICE length",numberOfStops,"--------------------------------------------------------------")
				var duration = 0;
				for (var j = 0; j < slice[0].segment.length; j++) {
					duration += slice[0].segment[j].leg[0].duration;
				}
				var t = {
					"cost":cost,
					"carrier":carrierDep,
					"depTime":depTime,
					"arrTime":arrTime,
					"numberOfStops": numberOfStops,
					"duration":duration
				}
				tripOptions.push(t);
			}
			//var airport = data.airport;
			var depCity = data.city[0].name;
			var destCity = data.city[data.city.length - 1].name;
			responseObj = {
				"tripOptions":tripOptions,
				"depCity":depCity,
				"destCity":destCity
			}
			console.log("----------------------------------------")
			console.log(responseObj);
			//getRes.send(JSON.parse(str));
			getRes.send(responseObj);
		}
		else{
			responseObj = {
				"tripOptions":[],
				"depCity":"",
				"destCity":""
			}
			console.log("----------------------------------------")
			console.log(responseObj);
			//getRes.send(JSON.parse(str));
			getRes.send(responseObj);
		}
	});
}

/*var data = querystring.stringify({
      username: yourUsernameValue,
      password: yourPasswordValue
    });*/

app.post('/api/qpx', function (postReq, res) {
	console.log(postReq.body);
	console.log(postReq.body.request.slice[0]);
	var req = https.request(optionsQpx, function(responseQpx) {
			callbackQpx(responseQpx,res);
		});
	req.write(JSON.stringify(postReq.body));
	req.end();
})



var server = app.listen(8081, function () {

	var host = server.address().address
	var port = server.address().port

	console.log("Example app listening at http://%s:%s", host, port)

})


//http://localhost:8081/api/hotels

