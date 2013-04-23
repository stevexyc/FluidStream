Meteor.subscribe 'Chats'

Template.chat.username = () ->
	Session.get 'username'

Template.chat.rendered = ->
	$('input#add-chat').tagahead
		mode: 'multiple'
		delimiter : ' '
		source: array1
		updater: (item) ->
			@$element.val().replace(/[^' ']*$/, "") + item + " "
		items: 20

Template.chat.events {
	'keyup #add-chat': (e,t) ->
		if e.which is 13
			itemEval = String(e.target.value || "") # to string
			tags = parseHashtag(itemEval) # get hashtags
			at = parseAtsign(itemEval) # get @ sign
			combined = parseAtsign(itemEval) 
			combined.push Session.get 'username'
			mainName = parseItem(itemEval, tags, at)
			if itemEval.charAt(0) is "="
				andChats(combined)
			else if itemEval.charAt(0) is "/"
				orChats(at)
			else if mainName.trim() is ''
				Session.set 'showing', 'default'
			else
				chats.insert {
					Chat: mainName, 
					Tags: tags, 
					At: at, 
					Status: 0, 
					owner: Meteor.userId(),
					ownername: Session.get 'username' 
					Everyone: combined
					Time: new Date().getTime()
				}
				e.target.value = ''
				Session.set 'respondAt', null

	'click .icon-ok' : (e,t) ->
		chats.update this._id, {$set: {Status: 1}}

	'click .icon-remove': (e,t) ->
		chats.remove {_id: this._id}

	'click .icon-comment': (e,t) ->
		# Session.set 'respondAt', this.ownername
		Deps.flush()
		respondText t.find('#add-chat'), this.ownername + ' '

}

Template.chat.chat = () ->
	if Session.equals 'showing', 'default'
		chats.find {}, {sort: {Time: -1}}
	else 
		chats.find(Session.get('showing'), {sort: {Time: -1}})

Template.chat.align = () ->
	if this.owner is Meteor.userId()
		'offset1'

Template.chat.ownername = () ->
	if this.owner is Meteor.userId()
		'Me'
	else 
		this.ownername

Template.chat.icon = () ->
	if this.owner is Meteor.userId()
		if this.Status is 0
			'icon-ok'
		else 
			'icon-remove'
	else 
		'icon-comment'

andChats = (combined)->
	results = []
	results.push Everyone: x for x in combined
	query = {$and:results}
	if results? and results[0]?
		Session.set 'showing', query
	else 
		Session.set 'showing', 'default'
	
orChats = (combined) ->
	results = []
	results.push Everyone: x for x in combined
	query = {$or:results}
	if results? and results[0]?
		Session.set 'showing', query
	else 
		Session.set 'showing', 'default'