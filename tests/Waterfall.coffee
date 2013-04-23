lists = new Meteor.Collection('List');

if Meteor.is_client

	array1 = []

	Meteor.startup ->
		Meteor.autorun ->
			for item in lists.find({},{Tags:1}).fetch()
				for tag in item.Tags
					if tag not in array1
						array1.push tag
			for item in lists.find({},{At:1}).fetch()
				for at in item.At
					if at not in array1
						array1.push at

	# Tagahead Capability
	Template.items.rendered = ->
		Meteor.defer ->
			$('input#add-item').tagahead
				mode: 'multiple'
				delimiter : ' '
				source: array1
				updater: (item) ->
					@$element.val().replace(/[^' ']*$/, "") + item + " "
				items: 20

			$('input.edit_item').tagahead
				mode: 'multiple'
				delimiter : ' '
				source: array1
				updater: (item) ->
					@$element.val().replace(/[^' ']*$/, "") + item + " "
				items: 20

	
	Session.set 'zdate', ''

	Template.input.zDate = ->
		Session.get	'zdate'

	# Input Events
	Template.input.events = {
		'keyup #add-item' : (e,t) ->
			valdate = e.target.value.match(/\(([^)]+)\)/)
			# console.log valdate
			if valdate?
				zdate = Date.future (valdate[1])
				Session.set 'zdate', zdate.format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
				# console.log zdate

			if e.which is 13
				readItem(e,t)
				Session.set 'zdate', ''
	}

	# Individual Items 
	Template.items.Title = ->
		'@stevexyc'

	Session.set 'showing', 'default'
	Session.set 'item-editing', null
	Session.set 'zdate2', ''
	
	Template.items.zDate2 = ->
		Session.get 'zdate2'

	Template.items.item = ->
		if Session.equals 'showing', 'default'
			lists.find {}, {sort: {Status: 1}}
		else 
			lists.find(Session.get('showing'), {sort: {Status: 1}})

	Template.items.Tags = ->
		this.Tags

	Template.items.At = ->
		this.At

	Template.items.Class = ->
		if this.Status is 0 
			'alert-info'
		else 
			'alert-error'

	Template.items.Icon = ->
		if this.Status is 0 
			'icon-ok'
		else 
			'icon-remove'

	Template.items.Editing = ->
		Session.equals 'item-editing', this._id

	Template.items.events = {
		'dblclick .item' : (e,t) -> # double click 
			Session.set 'item-editing', this._id
			Session.set 'zdate2', this.zDate
			Meteor.flush()
			focusText t.find('.edit_item')

		'keyup .edit_item' : (e,t) ->
			valdate = e.target.value.match(/\(([^)]+)\)/)
			# console.log valdate
			if valdate?
				zdate = Date.future (valdate[1])
				Session.set 'zdate2', zdate.format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
				# console.log zdate

			if e.which is 13 
				# console.log this._id
				updateItem(e,t, this._id)

		'focusout .edit_item' : (e,t) ->
			Session.set 'item-editing', null
			Session.set 'zdate2', ''

		'click .icon-ok' : (e,t) ->
			console.log 'checked'
			lists.update this._id, {$set: {Status: 1}}

		'click .icon-remove' : (e,t) ->
			lists.remove this._id
	}

	readItem = (e,t) ->
		itemEval = String(e.target.value || "") # to string
		tags = parseHashtag(itemEval) # get hashtags
		at = parseAtsign(itemEval) # get @ sign
		if e.target.value.match(/\(([^)]+)\)/)?
			valdate = e.target.value.match(/\(([^)]+)\)/)[0]
		zdate = Session.get 'zdate' # get Dates
		mainName = parseItem(itemEval, tags, at, valdate) # get item name
		# console.log itemEval, mainName, tags, at #test
		if itemEval.charAt(0) is "="
			console.log itemEval.charAt 0
			andItems(tags, at)
		else if itemEval.charAt(0) is "/"
			orItems(tags, at)
		else if mainName.trim() is ''
			Session.set 'showing', 'default'
		else
			lists.insert {Input: itemEval, Name: mainName, Tags: tags, At: at, zDate: zdate, Status: 0}
			e.target.value = ''

	updateItem = (e,t, id) ->
		itemEval = String(e.target.value || "") # to string
		tags = parseHashtag(itemEval) # get hashtags
		at = parseAtsign(itemEval) # get @ sign 
		if e.target.value.match(/\(([^)]+)\)/)?
			valdate = e.target.value.match(/\(([^)]+)\)/)[0]
		zdate = Session.get 'zdate2' # get Dates
		mainName = parseItem(itemEval, tags, at, valdate) # get item name		
		if mainName.trim() is ''
			lists.remove({_id:id})
			Session.set 'item-editing', null
			return false
		if id?
			console.log 'id exists'
			lists.remove({_id:id})
		else 
			Session.set 'item-editing', null
			return false
		lists.insert {Input: itemEval, Name: mainName, Tags: tags, At: at, zDate: zdate, Status: 0}
		Session.set 'item-editing', null
		e.target.value = ''
		console.log 'updateItem finished'

	parseHashtag = (theItem) ->
		theItem.match(/(#[A-Za-z0-9\-\_]+)/g) or []

	parseAtsign = (theItem) ->
		theItem.match(/(@[A-Za-z0-9\-\_]+)/g) or []

	parseItem = (Main, tags, at, valdate) ->
		if Main? and tags? and at?
			for item in tags
				Main = Main.replace(item, "")
			for item in at
				Main = Main.replace(item, "")
		Main = Main.replace(valdate,"")
		Main

	orItems = (tags, at) ->
		results = []
		results.push Tags: x for x in tags
		results.push At: y for y in at
		console.log results
		query = {$or:results}
		# console.log query
		if results? and results[0]?
			Session.set 'showing', query
		else 
			Session.set 'showing', 'default'

	andItems = (tags, at) ->
		results = []
		results.push Tags: x for x in tags
		results.push At: y for y in at
		console.log results
		query = {$and:results}
		# console.log query
		if results? and results[0]?
			Session.set 'showing', query
		else 
			Session.set 'showing', 'default'

	focusText = (i) ->
		i.focus()
		i.select()



if Meteor.is_server
	Meteor.publish 'Items', -> lists.find

