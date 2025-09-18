class Api::V1::FlagsController < Api::V1::BaseController
  before_action :set_flag, only: [ :show, :update, :destroy, :evaluate ]

  def index
    @flags = Flag.includes(:rules).order(:name)
    render json: @flags.as_json(include: :rules)
  end

  def show
    render json: @flag.as_json(include: :rules)
  end

  def create
    @flag = Flag.new(flag_params)

    if @flag.save
      render json: @flag.as_json(include: :rules), status: :created
    else
      render json: { errors: @flag.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @flag.update(flag_params)
      render json: @flag.as_json(include: :rules)
    else
      render json: { errors: @flag.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @flag.destroy
    head :no_content
  end

  def evaluate
    # Accept user attributes from the client application
    user_attributes = params[:user_attributes] || {}
    user_id = params[:user_id] || user_attributes["id"]

    context = {
      user_id: user_id,
      user_attributes: user_attributes
    }

    result = FlagEvaluationService.new(@flag, context).evaluate

    render json: {
      flag_name: @flag.name,
      enabled: result[:enabled],
      rule_type: result[:rule_type],
      rule_id: result[:rule_id]
    }
  end

  private

  def set_flag
    @flag = Flag.find_by!(name: params[:flag_name] || params[:id])
  end

  def flag_params
    params.require(:flag).permit(:name, :description, :enabled)
  end
end
