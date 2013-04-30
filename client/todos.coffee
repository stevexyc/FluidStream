Session.set 'zdate', ''
Session.set 'showing', 'default'
Session.set 'item-editing', null

# Tagahead Capability
Template.items.rendered = ->
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

Template.items.zDate = ->
	if Session.equals 'item-editing', null
		Session.get('zdate')

Template.items.zDate2 = ->
	Session.get('zdate')

# username
Template.items.username = ->
	Session.get('username')

Template.items.item = ->
	if Session.equals 'showing', 'default'
		lists.find {}, {sort: {Status: 1, Time: -1}}
	else 
		lists.find(Session.get('showing'), {sort: {Status: 1, Time: -1}})

Template.items.Date = ->
	if this.zDate?
		if Date.create(this.zDate).isValid()
			Date.create(this.zDate).format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')

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
	'keyup #add-item' : (e,t) ->
		valdate = e.target.value.match(/\(([^)]+)\)/)
		if valdate?
			zdate = Date.future (valdate[1])
			Session.set 'zdate', zdate.format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
			Session.set 'savedate', zdate.getTime()

		if e.which is 13
			readItem(e,t)
			Session.set 'zdate', ''
			Session.set 'savedate', null

	'dblclick .item' : (e,t) -> # double click 
		Session.set 'item-editing', this._id
		if this.zDate? and Date.create(this.zDate).isValid()
			tmp = Date.create(this.zDate).format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
			Session.set 'zdate', tmp
		else 
			Session.set 'zdate', ''
		Deps.flush()
		focusText t.find('.edit_item')

	'keyup .edit_item' : (e,t) ->
		valdate = e.target.value.match(/\(([^)]+)\)/)
		if valdate?
			zdate = Date.future (valdate[1])
			Session.set 'zdate', zdate.format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
			Session.set 'savedate', zdate.getTime()

		if e.which is 13 
			updateItem(e,t, this._id)
			Session.set 'zdate', ''
			Session.set 'savedate', null

	'focusout .edit_item' : (e,t) ->
		Session.set 'item-editing', null
		Session.set 'zdate', ''
		Session.set 'savedate', null

	'click .icon-ok' : (e,t) ->
		lists.update this._id, {$set: {Status: 1}}

	'click .icon-remove' : (e,t) ->
		lists.remove this._id
}

@readItem = (e,t) ->
	itemEval = String(e.target.value || "") # to string
	tags = parseHashtag(itemEval) # get hashtags
	at = parseAtsign(itemEval) # get @ sign
	if e.target.value.match(/\(([^)]+)\)/)?
		valdate = e.target.value.match(/\(([^)]+)\)/)[0]
	zdate = Session.get 'savedate' # get Dates
	mainName = parseItem(itemEval, tags, at, valdate) # get item name
	if itemEval.charAt(0) is "="
		console.log itemEval.charAt 0
		andItems(tags, at)
	else if itemEval.charAt(0) is "/"
		orItems(tags, at)
	else if mainName.trim() is ''
		Session.set 'showing', 'default'
	else
		lists.insert {
			Input: itemEval, 
			Name: mainName, 
			Tags: tags, 
			At: at, 
			zDate: zdate, Status: 0, 
			owner: Meteor.userId(), 
			Time: Date.create().toISOString()
		}
		e.target.value = ''
		Session.set 'savedate', null

@updateItem = (e,t, id) ->
	itemEval = String(e.target.value || "") # to string
	tags = parseHashtag(itemEval) # get hashtags
	at = parseAtsign(itemEval) # get @ sign 
	if e.target.value.match(/\(([^)]+)\)/)?
		valdate = e.target.value.match(/\(([^)]+)\)/)[0]
	zdate = Session.get 'savedate' # get Dates
	mainName = parseItem(itemEval, tags, at, valdate) # get item name		
	if mainName.trim() is ''
		lists.remove({_id:id})
		Session.set 'item-editing', null
		return false
	if id?
		lists.remove({_id:id})
	else 
		Session.set 'item-editing', null
		return false
	lists.insert {
		Input: itemEval, 
		Name: mainName, 
		Tags: tags, 
		At: at, 
		zDate: zdate, 
		Status: 0, 
		owner: Meteor.userId(), 
		Time: Date.create().toISOString()
	}
	Session.set 'item-editing', null
	e.target.value = ''
	Session.set 'savedate', null



