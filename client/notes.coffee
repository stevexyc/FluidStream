Meteor.subscribe 'Notes'

Session.set 'current-note', null

Template.notes.rendered = ->
	$('input#add-note').tagahead
		mode: 'multiple'
		delimiter : ' '
		source: array1
		updater: (item) ->
			@$element.val().replace(/[^' ']*$/, "") + item + " "
		items: 20

	$('textarea#note').tagahead
		mode: 'multiple'
		delimiter : ' '
		source: array1
		updater: (item) ->
			@$element.val().replace(/[^' ']*$/, "") + item + " "
		items: 20

Template.notes.events {
	'keyup #add-note' : (e,t) ->
		if e.which is 13 
			addNote(e,t)

	'click .notetitle' : (e,t) ->
		Session.set 'current-note', this._id

	'keyup #note' : (e,t) ->
		if e.which is 13 
			updateNote(e,t)

	'focusout #note' : (e,t) ->
		updateNote(e,t)

	'click .icon-ok' : (e,t) ->
		notes.update this._id, {$set: {Status: 1}}

	'click .icon-remove' : (e,t) ->
		notes.remove {_id: this._id}
		Session.set 'current-note', null

	'dblclick .notetitle' : (e,t) ->
		Session.set 'item-editing', this._id
		Meteor.flush()
		focusText t.find('.edit_note')

	'focusout .edit_note' : (e,t) ->
		Session.set 'item-editing', null

	'keyup .edit_note': (e,t) ->
		if e.which is 13
			itemEval = String(e.target.value || "")
			if itemEval.trim() is ''
				notes.remove {_id:this._id}
				Session.set 'item-editing', null
			else
				notes.update this._id, {$set: {Title: itemEval}}
				Session.set 'item-editing', null
		
}

Template.notes.username = ->
	Session.get 'username'

Template.notes.note = (e,t) ->
	if Session.equals 'showing', 'default'
		notes.find {}, {sort:{Status: 1, Time: -1}}
	else 
		notes.find(Session.get('showing'), {sort: {Status: 1, Time: -1}})

Template.notes.selected = (e,t) ->
	if Session.equals 'current-note', this._id
		'white'

Template.notes.icon = (e,t) ->
	if this.Status is 0 
		'icon-ok'
	else 
		'icon-remove'

Template.notes.status = ->
	if this.Status is 1
		'done'

Template.notes.selectedNote = ->
	if Session.equals 'current-note', null
		false 
	else 
		true

Template.notes.editing = ->
	Session.equals 'item-editing', this._id

Template.notes.Text = (e,t) ->
	if Session.get('current-note') is null
		return ''
	else
		note = notes.findOne {_id: Session.get('current-note') }
		if note? and note.Text?
			note.Text

addNote = (e,t) ->
	itemEval = String(e.target.value || "") # to string
	tags = parseHashtag(itemEval) # get hashtags
	at = parseAtsign(itemEval) # get @ sign
	Session.set 'current-note', null
	if itemEval.charAt(0) is "="
		andItems(tags, at)
	else if itemEval.charAt(0) is "/"
		orItems(tags, at)
	else if itemEval.trim() is ''
		Session.set 'showing', 'default'
	else 
		notes.insert {
			Title: itemEval,
			Tags: []
			At: []
			Status: 0,
			owner: Meteor.userId(), 
			Time: new Date().getTime()
		}, 
		(error, result) -> 
			Session.set 'current-note', result
			Deps.flush()
			focusText t.find('#note')
		e.target.value = ''

updateNote = (e,t) ->	
	itemEval = String(e.target.value || "") # to string
	tags = parseHashtag(itemEval) # get hashtags
	at = parseAtsign(itemEval) # get @ sign
	notes.update Session.get('current-note'), 
	{$set: 
		{
			Text: itemEval,
			Tags: tags, 
			At: at,  
			Status: 0,
			Time: new Date().getTime()
		}
	}

