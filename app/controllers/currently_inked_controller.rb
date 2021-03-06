class CurrentlyInkedController < ApplicationController
  before_action :authenticate_user!
  before_action :retrieve_currently_inkeds, only: [:index, :edit, :create, :update]
  before_action :retrieve_currently_inked, only: [:edit, :update, :destroy]

  def index
    @currently_inked = CurrentlyInked.new(user: current_user)
    @archival_currently_inked = CurrentlyInked.new(user: current_user, archived_on: Date.today)
    respond_to do |format|
      format.html
      format.csv do
        cis = current_user.currently_inkeds.includes(:collected_pen, :collected_ink)
        send_data cis.to_csv, type: "text/csv", filename: "currently_inked.csv"
      end
    end
  end

  def edit
    render :index
  end

  def create
    @currently_inked = CurrentlyInked.new(user: current_user)
    @archival_currently_inked = CurrentlyInked.new(user: current_user, archived_on: Date.today)
    record = current_user.currently_inkeds.build(currently_inked_params)
    if record.archived?
      @archival_currently_inked = record
    else
      @currently_inked = record
    end
    if record.save
      record.collected_ink.update(used: true)
      anchor = record.archived? ? "archive-add-form" : "add-form"
      redirect_to currently_inked_index_path(anchor: anchor)
    else
      @elementToScrollTo = "#add-form"
      render :index
    end
  end

  def update
    if @record.update(currently_inked_params)
      @record.collected_ink.update(used: true)
      redirect_to currently_inked_index_path(anchor: @record.id)
    else
      @elementToScrollTo = "##{@record.id}"
      render :index
    end
  end

  def destroy
    @record&.destroy
    redirect_to currently_inked_index_path
  end

  private

  def currently_inked_params
    params.require(:currently_inked).permit(
      :collected_ink_id,
      :collected_pen_id,
      :inked_on,
      :archived_on,
      :comment
    )
  end

  def retrieve_currently_inkeds
    @currently_inkeds = current_user.currently_inkeds.active.includes(:collected_pen, :collected_ink).sort_by {|ci| "#{ci.pen_name} #{ci.ink_name}"}
    @archived = current_user.currently_inkeds.archived.includes(:collected_pen, :collected_ink).order('archived_on DESC, created_at DESC')
  end

  def retrieve_currently_inked
    @record = current_user.currently_inkeds.find_by(id: params[:id])
    if @record&.archived?
      @archival_currently_inked = @record
      @currently_inked = CurrentlyInked.new(user: current_user)
    else
      @currently_inked = @record
      @archival_currently_inked = CurrentlyInked.new(user: current_user, archived_on: Date.today)
    end
  end
end
