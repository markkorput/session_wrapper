class SessionWrapper
	def initialize(session_hash = nil)
		@data = session_hash || {}
	end

	# make sure we never get a nil
	def data
		@data || {}.with_indifferent_access
	end

	# keep track of current user id
	def user_id
		data[:current_user_id]
	end

	def user
		@user ||= User.find_by_id(self.user_id) if self.user_id.present?
	end

	def user_login_at
		data[:current_user_login_at].present? ? Time.at(data[:current_user_login_at].to_i) : nil
	end

	def user_id=(new_user_id)
		# reset the @user instance var, because that might still be initialized to the old user
		@user = nil

		# set session data
		data[:current_user_id] = new_user_id
		data[:current_user_login_at] = Time.now.to_i

		# clean "switch user" backlog on logout
		data.delete(:previous_user_ids) if new_user_id.blank?
	end

	def user=(new_user)
		self.user_id = new_user.try(:id)
	end

	# "login as user"
	def previous_user?
		previous_user_id.present?
	end

	def previous_user_ids
		data[:previous_user_ids] || []
	end

	def previous_user_id
		previous_user_ids.last
	end

	def previous_user
		User.find_by_id(previous_user_id) if previous_user_id.present?
	end

	def original_user_id
		previous_user_ids.first
	end

	def original_user
		self.original_user_id.present? ? User.find_by_id(original_user_id) : self.user
	end

	# switch to new user and remember current user
	def switch_user_id(new_user_id)
		data[:previous_user_ids] = previous_user_ids + [user_id].compact
		self.user_id = new_user_id
	end

	def switch_user(new_user)
		self.switch_user_id(new_user.id)
	end

	# switch back to previous user
	def switch_back
		self.user_id = data[:previous_user_ids].pop # if previous_user?
	end

	def switch_to_original_user
		self.user_id = original_user_id # if previous_user?
		data.delete(:previous_user_ids)
	end
end
