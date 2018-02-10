class CollectedPensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_flash
  before_action :retrieve_collected_pens, only: [:index, :edit, :create, :update]
  before_action :retrieve_collected_pen, only: [:edit, :update, :destroy]

  def index
    @collected_pen = CollectedPen.new
  end

  def edit
    render :index
  end

  def create
    @collected_pen = current_user.collected_pens.build(collected_pen_params)
    if @collected_pen.save
      redirect_to collected_pens_path(anchor: "add-form")
    else
      @elementToScrollTo = "#add-form"
      render :index
    end
  end

  def update
    if @collected_pen.update(collected_pen_params)
      redirect_to collected_pens_path(anchor: @collected_pen.id)
    else
      @elementToScrollTo = "##{@collected_pen.id}"
      render :index
    end
  end

  def destroy
    @collected_pen&.destroy
    redirect_to collected_pens_path
  end

  private

  def collected_pen_params
    params.require(:collected_pen).permit(
      :brand,
      :model,
      :nib,
      :color,
      :comment,
    )
  end

  def retrieve_collected_pen
    @collected_pen = current_user.collected_pens.find_by(id: params[:id])
  end

  def retrieve_collected_pens
    @collected_pens = current_user.collected_pens.order('brand, model')
  end

  def set_flash
    flash.now[:notice] = "Your pen collection is private and no one but you can see it. This is because pens can be worth quite a lot and I don't want to provide a list of people to rob. Maybe this will change in the future, but there will always be the possibility to keep this part private."
  end
end