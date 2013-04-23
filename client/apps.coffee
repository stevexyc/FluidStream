Session.set('showapp', 'faqapp')

Template.apps.listapp = () ->
	return Session.equals('showapp', 'listapp')

Template.apps.calapp = () ->
	return Session.equals('showapp', 'calapp')

Template.apps.notesapp = () ->
	return Session.equals('showapp', 'notesapp')

Template.apps.chatapp = () ->
	return Session.equals('showapp', 'chatapp')

Template.apps.faqapp = () ->
	return Session.equals('showapp', 'faqapp')

Template.apps.events {
	'click #show-todos': (e,t) ->
		Session.set 'showapp', 'listapp'
		Session.set 'showing', 'default'

	'click #show-calendar': (e,t) ->
		Session.set 'showapp', 'calapp'
		Session.set 'showing', 'default'

	'click #show-notes': (e,t) ->
		Session.set 'showapp', 'notesapp'
		Session.set 'showing', 'default'

	'click #show-faq': (e,t) ->
		Session.set 'showapp', 'faqapp'
		Session.set 'showing', 'default'

	'click #show-chat': (e,t) ->
		Session.set 'showapp', 'chatapp'
		Session.set	'showing', 'default'

}






Accounts.ui.config {
     passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'
}