class Api::V1::GroupsController < Api::V1::BaseController
  before_action :set_group, only: [:update, :destroy]

  def index
    @groups = Group.order(:name)
    render json: @groups
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created
    else
      render json: { errors: @group.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: { errors: @group.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    head :no_content
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :definition)
  end
end