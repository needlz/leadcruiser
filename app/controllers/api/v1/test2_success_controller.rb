class API::V1::Test2SuccessController  < ActionController::API
	def create
		render json: {:success => true}, status: :created
	end
end