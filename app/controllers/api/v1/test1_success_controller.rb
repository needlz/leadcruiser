class API::V1::Test1SuccessController  < ActionController::API
	def create
		render json: {:success => true}, status: :created
	end
end