# Meteor.subscribe 'Calendar'

Template.calendar.events {
	'keyup #add-event' : (e,t)->
		valdate = e.target.value.match(/\(([^)]+)\)/)
		if valdate?
			zdate = Date.future (valdate[1])
			Session.set 'zdate', zdate.format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
			Session.set 'savedate', zdate.getTime()

		if e.which is 13
			addevent(e,t)
			Session.set 'zdate', ''
			Session.set 'savedate', ''
}
# Tagahead Capability
Template.calendar.rendered = ->
	$('input#add-event').tagahead
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

Template.calendar.zDate = ->
	if Session.equals 'item-editing', null
		Session.get 'zdate'

Template.calendar.zDate2 = ->
	Session.get 'zdate'

Template.calendar.username = ->
	Session.get 'username'

Template.calendar.Days = () ->
	for day in Date.range('the beginning of this week', '2 weeks from today').eachDay()
		Dowdd = Date.create(day).format('{Dow} {dd}')
		day1 = Date.create(day).endOfDay()
		{
			ti: Dowdd
			Items: lists.find({Status:0, zDate: {$gte: day.getTime(), $lte: day1.getTime()}}, {sort: {zDate:1}}).fetch()
		}

Template.calendar.Date = ()->
	tmp = Date.create(this.zDate).format('{12hr}:{mm}{tt}')
	if tmp is '12:00am'
		'all-day'
	else 
		tmp

Template.calendar.Editing = ->
	Session.equals 'item-editing', this._id

Template.calendar.events {
	'keyup #add-event': (e,t) ->
		valdate = e.target.value.match(/\(([^)]+)\)/)
		if valdate?
			zdate = Date.future (valdate[1])
			Session.set 'zdate', zdate.format('{Dow} {M}/{dd} {12hr}:{mm}{tt}')
			Session.set 'savedate', zdate.getTime()

		if e.which is 13
			addevent(e,t)
			Session.set 'zdate', ''
			Session.set 'savedate', null

	'focusout #add-event': (e,t) ->
		Session.set 'zdate', ''
		Session.set 'savedate', null

	'click .icon-ok' : (e,t) ->
		lists.update this._id, {$set: {Status: 1}}

	'dblclick .evnt': (e,t) ->
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
			updateevent(e,t, this._id)
			Session.set 'zdate', ''
			Session.set 'savedate', null

	'focusout .edit_item': (e,t) ->
		Session.set 'item-editing', null
		Session.set 'zdate', ''
		Session.set 'savedate', null

}

addevent = (e,t) ->
	itemEval = String(e.target.value || "") # to string
	tags = parseHashtag(itemEval) # get hashtags
	at = parseAtsign(itemEval) # get @ sign
	if e.target.value.match(/\(([^)]+)\)/)?
		valdate = e.target.value.match(/\(([^)]+)\)/)[0]
	zdate = Session.get 'savedate' # get Dates
	mainName = parseItem(itemEval, tags, at, valdate) # get item name
	if itemEval.charAt(0) is "="
		console.log itemEval.charAt 0
	else if itemEval.charAt(0) is "/"
		console.log 'cal or-items'
	else if mainName.trim() is ''
		Session.set 'showing', 'default'
	else
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
		e.target.value = ''
		Session.set 'savedate', null

updateevent = (e,t, id) ->
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

