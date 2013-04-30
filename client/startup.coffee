Meteor.subscribe 'Lists'

@array1 = []

Meteor.startup ->
	Deps.autorun ->
		for item in lists.find({}).fetch()
			for tag in item.Tags
				if tag not in array1
					array1.push tag
		for item in lists.find({}).fetch()
			for at in item.At
				if at not in array1
					array1.push at
		for item in notes.find({}).fetch()
			for tag in item.Tags
				if tag not in array1
					array1.push tag
		for item in notes.find({}).fetch()
			for at in item.At
				if at not in array1
					array1.push at
		for item in chats.find({}).fetch()
			for tag in item.Tags
				if tag not in array1
					array1.push tag
		for item in chats.find({}).fetch()
			for at in item.At
				if at not in array1
					array1.push at
		if Meteor.user()?
			Session.set 'username', '@' + Meteor.user().username

@parseHashtag = (theItem) ->
	theItem.match(/(#[A-Za-z0-9\-\_]+)/g) or []

@parseAtsign = (theItem) ->
	theItem.match(/(@[A-Za-z0-9\-\_]+)/g) or []

@parseItem = (Main, tags, at, valdate) ->
	if Main? and tags? and at?
		for item in tags
			Main = Main.replace(item, "")
		for item in at
			Main = Main.replace(item, "")
	Main = Main.replace(valdate,"")
	Main

@orItems = (tags, at) ->
	results = []
	results.push Tags: x for x in tags
	results.push At: y for y in at
	# console.log results
	query = {$or:results}
	# console.log query
	if results? and results[0]?
		Session.set 'showing', query
	else 
		Session.set 'showing', 'default'

@andItems = (tags, at) ->
	results = []
	results.push Tags: x for x in tags
	results.push At: y for y in at
	# console.log results
	query = {$and:results}
	# console.log query
	if results? and results[0]?
		Session.set 'showing', query
	else 
		Session.set 'showing', 'default'

@focusText = (i) ->
	i.focus()
	i.select()

@respondText = (i, val) ->
	i.focus()
	i.value = (if val then val else "")
