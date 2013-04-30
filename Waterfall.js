lists = new Meteor.Collection('List');
notes = new Meteor.Collection('Notes');
chats = new Meteor.Collection('Chats');

function adminUser(userId) {
     var adminUser = Meteor.users.findOne({username:"admin"});
     return (userId && adminUser && userId === adminUser._id);
   };

lists.allow({
    insert: function(userId, doc){ 
    	return (adminUser(userId) || (userId && doc.owner === userId)); 
    },
	update: function(userId, doc, fieldNames, modifier){ 
		return (adminUser(userId) || (userId && doc.owner === userId));
	},
	remove: function (userId, doc){ 
		return (adminUser(userId) || (userId && doc.owner === userId));
	}
});

notes.allow({
    insert: function(userId, doc){ 
    	return (adminUser(userId) || (userId && doc.owner === userId)); 
    },
	update: function(userId, doc, fieldNames, modifier){ 
		return (adminUser(userId) || (userId && doc.owner === userId));
	},
	remove: function (userId, doc){ 
		return (adminUser(userId) || (userId && doc.owner === userId));
	}
});

chats.allow({
    insert: function(userId, doc){ 
    	return (adminUser(userId) || (userId && doc.owner === userId)); 
    },
	update: function(userId, doc, fieldNames, modifier){ 
		return (adminUser(userId) || (userId && doc.owner === userId));
	},
	remove: function (userId, doc){ 
		return (adminUser(userId) || (userId && doc.owner === userId));
	}
});