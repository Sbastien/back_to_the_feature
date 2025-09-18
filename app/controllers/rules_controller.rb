class RulesController < ApplicationController
  before_action :set_flag
  before_action :set_rule, only: [ :edit, :update, :destroy ]

  def new
    @rule = @flag.rules.build
  end

  def create
    @rule = @flag.rules.build(rule_params)

    if @rule.save
      redirect_to @flag, notice: "Rule was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @rule.update(rule_params)
      redirect_to @flag, notice: "Rule was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    redirect_to @flag, notice: "Rule was successfully deleted."
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
