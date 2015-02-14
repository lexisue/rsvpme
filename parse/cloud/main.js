var _ = require('underscore.js');

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
	var total;
	var attend;
	
	query.find().then(function(results){
		total = results.length;
	}), function(error){
		response.error('Error querying users');
		return;
	}
	
	query.equalTo('isCheckedIn', 'true');

		query.find().then(function(results){
		attend = results.length;
		
		var toReturn = {};
		toReturn.message = attend + ' attending, ' + total + ' total';
		response.success(toReturn);
	}), function(error){
		response.error('Error querying users');
	}
	
});


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
