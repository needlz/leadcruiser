class VisitorsController < ApplicationController

	http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

	def home
	end
end