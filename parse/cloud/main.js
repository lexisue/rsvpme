var _ = require('underscore.js');

Parse.Cloud.define("checkIn", function(request, response) {
	if (!request.params.userId) {
		response.error("user is missing");
		return;
	}

	var query = new Parse.Query(Parse.User);
	query.equalTo("objectId", request.params.userId);
	query.first({
		success: function(foundUser) {
			foundUser.set("isCheckedIn", true);
			Parse.Cloud.useMasterKey();

			foundUser.save(null, {
				success: function(result) {
					var pushQuery = new Parse.Query(Parse.Installation);
					pushQuery.equalTo('deviceType', 'ios');
					    
					Parse.Push.send({
					  where: pushQuery, // Set our Installation query
					  data: {
					    alert: result.get('firstName') + ' ' + result.get('lastName') + ' just checked in!'
					  }
					}, {
					  success: function() {
					    // Push was successful
					    console.log('Push success');
					  },
					  error: function(error) {
					    throw "Got an error " + error.code + " : " + error.message;
					  }
					});

					var toReturn = {};
					toReturn.code = 200;
					toReturn.user = result;
					response.success(toReturn);
				},
				error: function(error) {
					response.error(error);
				}
			});
		},
		error: function(error) {
			response.error(error);
		}
	});
});


Parse.Cloud.define("getGuestList", function(request, response) {

	var query = new Parse.Query(Parse.User);

	query.find().then(function(results) {

		var toReturn = {};
		toReturn.code = 200;
		toReturn.items = results;
		response.success(toReturn);
	}), function (error) {
		response.error('Error querying users');
	}
});

Parse.Cloud.define("attendance", function(request, response){

	var query = new Parse.Query(Parse.User);
	query.equalTo('isGuest', true);
	var total;
	var attend;

	query.count().then(function(count) {
		total = count;

		var checkedInQuery = new Parse.Query(Parse.User);
		checkedInQuery.equalTo('isCheckedIn', true);
		checkedInQuery.equalTo('isGuest', true);

		checkedInQuery.count().then(function(count) {

			var toReturn = {};
			toReturn.code = 200;
			toReturn.message = count + ' out of ' + total + ' are already here!';
			response.success(toReturn);
		}), function (error) {
			response.error('Error getting checked in');
		}
	}), function(error) {
		response.error('Error counting');
	}
	
});


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
