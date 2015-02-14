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
					Parse.Cloud.useMasterKey();
					var pushQuery = new Parse.Query(Parse.Installation);
					pushQuery.equalTo('deviceType', 'ios');
					pushQuery.equalTo('channels', 'hostApp');

					// send a push if they're on the watch list for the host app
					if (result.get('shouldPush') == true) {
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
					}

					// set the return object
					var toReturn = {};
					toReturn.code = 200;
					toReturn.user = result;
					//response.success(toReturn);

					// Event management on a successful check in
					var eventQuery = new Parse.Query('Event');
					eventQuery.first({
					
						success: function(object){
							_.extend(object, Parse.Events);
							object.trigger('checkIn');
						},
						
						error: function(object, error){
							response.error('Could not find event dispatcher.');
						}
					});


					var checkedInQuery = new Parse.Query(Parse.User);
					checkedInQuery.equalTo('isGuest', true);
					checkedInQuery.find({
						success: function(results) {
							var checkedInCount = 0;
							_.each(results, function(result) {
								if (result.get('isCheckedIn') == true) {
									checkedInCount++;
								}
							});

							var percentage = (checkedInCount / results.length) * 100;

							// look for a threshold in the range for this percentage
							var thresholdQuery = new Parse.Query("PushThreshold");
							thresholdQuery.lessThanOrEqualTo('percentage', percentage);
							thresholdQuery.equalTo('hasSent', false);
							thresholdQuery.ascending('percentage');
							thresholdQuery.first({
								success: function(result) {

									var shouldSend = 0;

									if (result) {
										var percentagePushQuery = new Parse.Query(Parse.Installation);
										percentagePushQuery.equalTo('deviceType', 'ios');
										Parse.Push.send({
										  where: percentagePushQuery, // Set our Installation query
										  data: {
										    alert: '' + result.get('percentageText') + ' of the guests has already checked in!'
										  }
										}, {
										  success: function() {
										    // Push was successful
										    result.set('hasSent', true);
										    result.save();
										    response.success(toReturn);
										  },
										  error: function(error) {
										    throw "Got an error " + error.code + " : " + error.message;
										    response.success(toReturn);
										  }
										});
									}
									else {
										// no thresold to push so just return
										response.success(toReturn);
									}
								},
								error: function(error) {
									console.error('Problem getting thresholds');
									response.success(toReturn);
								}
							});
						},
						error: function(error) {
							console.error('Error trying to determine percentage checked in');
							response.success(toReturn);
						}
					});

					
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
	query.equalTo('isGuest', true);
	query.ascending('lastName,firstName');

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
			toReturn.message = count + ' of ' + total + ' guests are already here!';
			response.success(toReturn);
		}), function (error) {
			response.error('Error getting checked in');
		}
	}), function(error) {
		response.error('Error counting');
	}
	
});

Parse.Cloud.define("test", function(request, response) {

	Parse.Cloud.useMasterKey();
	var query = new Parse.Query(Parse.Installation);
	query.containsAll('channels', ['hostApp']);


	query.find({
		success: function(results) {
			var toReturn = {};
			toReturn.code = 200;
			toReturn.items = results;
			response.success(toReturn);
		},
		error: function(error) {
			response.error(error);
		}
	});
});
