module SessionWrapperHelper
	def current_session
		@current_session ||= SessionWrapper.new(session)
	end
end