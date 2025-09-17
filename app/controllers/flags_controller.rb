class FlagsController < ApplicationController
  before_action :set_flag, only: [:show, :edit, :update, :destroy]

  def index
    @flags = Flag.includes(:rules).order(:name)
  end

  def show
    @rules = @flag.rules.ordered
  end

  def new
    @flag = Flag.new
  end

  def create
    @flag = Flag.new(flag_params)

    if @flag.save
      redirect_to @flag, notice: "Flag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @flag.update(flag_params)
      redirect_to @flag, notice: "Flag was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @flag.destroy
    redirect_to flags_path, notice: "Flag was successfully deleted."
  end

  private

  def set_flag
    @flag = Flag.find(params[:id])
  end

  def flag_params
    params.require(:flag).permit(:name, :description, variants: [:name, :weight])
  end
end