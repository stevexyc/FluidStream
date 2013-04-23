Meteor.publish 'Lists', -> lists.find({owner: this.userId})
Meteor.publish 'Notes', -> notes.find({owner: this.userId})
# Meteor.publish 'Chats', -> chats.find({})
Meteor.publish 'Chats', -> chats.find({$or: [{owner: this.userId}, {At: getUsername(this.userId)}]})
# Meteor.publish 'Chats', -> chats.find({$or: [{owner: this.userId}, {At: user}]})


getUsername = (id) ->
	user = Meteor.users.findOne {_id: id}
	if user?
		username = user.username
		return '@'+username
	


	