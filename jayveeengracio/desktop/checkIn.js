Parse.Cloud.define("checkIn", function(UserID)
{
	var query = new Parse.Query(Parse.User)
	query.equalTo("objectID", UserID);
	query.find({
		success: function(){
			query.set("isCheckedIn", true);
			respnse.success("You are checked in!");

			},
		error: function(error){
			response.error("Error, ID does not exist!");
		}

	});

}