class Api::V1::RulesController < Api::V1::BaseController
  before_action :set_flag
  before_action :set_rule, only: [ :update, :destroy ]

  def index
    render json: @flag.rules.ordered
  end

  def create
    @rule = @flag.rules.build(rule_params)

    if @rule.save
      render json: @rule, status: :created
    else
      render json: { errors: @rule.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @rule.update(rule_params)
      render json: @rule
    else
      render json: { errors: @rule.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    head :no_content
  end

  private

  def set_flag
    @flag = Flag.find(params[:flag_id])
  end

  def set_rule
    @rule = @flag.rules.find(params[:id])
  end

  def rule_params
    params.require(:rule).permit(:type, :value)
  end
end
