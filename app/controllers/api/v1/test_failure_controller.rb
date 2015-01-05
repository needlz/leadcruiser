class API::V1::TestFailureController  < ActionController::API
	def create
		render json: {errors: "The email address of this lead was duplicated"}, status: :unprocessable_entity and return
	end
end