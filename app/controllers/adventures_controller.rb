class AdventuresController < ApplicationController
  include Push

  before_filter :find_adventure, :only => [ :show, :edit, :update, :destroy, :reorder_stepstones, :join ]
  before_filter :owner_only, :only => [  :edit, :update, :destroy, :reorder_stepstones ]
  before_filter :authenticate_user!, :only => [  :new, :create, :join ]

  # GET /adventures
  # GET /adventures.json
  def index
    @adventures = Adventure.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @adventures }
    end
  end

  # GET /adventures/1
  # GET /adventures/1.json
  def show
    @steps = @adventure.steps.includes(:stepstone).includes(:user)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @adventure }
    end
  end

  # GET /adventures/new
  # GET /adventures/new.json
  def new
    @adventure = Adventure.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @adventure }
    end
  end

  # GET /adventures/1/edit
  def edit
  end

  # POST /adventure/:id/join
  # POST /adventure/:id/join.json
  def join
    @adventure.stepstones.each do |stone|
      Rails.logger.warn("try to create #{stone} for #{current_user}")
      stone.steps.create( :user_id => current_user.id )
    end
    broadcast_adventure_board( @adventure )
    redirect_to @adventure
  end

  # POST /adventure/:id/reorder_stepstones
  # POST /adventure/:id/reorder_stepstones.json
  def reorder_stepstones
    params[:stepstone].each_with_index do |id, index|
      Stepstone.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

  # POST /adventures
  # POST /adventures.json
  def create
    params[:adventure][:user_id] = current_user.id
    @adventure = Adventure.new(params[:adventure])

    respond_to do |format|
      if @adventure.save
        format.html { redirect_to @adventure, notice: 'Adventure was successfully created.' }
        format.json { render json: @adventure, status: :created, location: @adventure }
      else
        format.html { render action: "new" }
        format.json { render json: @adventure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /adventures/1
  # PUT /adventures/1.json
  def update
    respond_to do |format|
      if @adventure.update_attributes(params[:adventure])
        format.html { redirect_to @adventure, notice: 'Adventure was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @adventure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /adventures/1
  # DELETE /adventures/1.json
  def destroy
    @adventure.destroy

    respond_to do |format|
      format.html { redirect_to adventures_url }
      format.json { head :no_content }
    end
  end

  private

  def find_adventure
    @adventure = Adventure.includes(:stepstones).find(params[:id])
  end

  def owner_only
    if current_user != @adventure.user then
      Rails.logger.warn("access to #{@adventure} blocked for user #{current_user}")
      redirect_to adventures_path, notice: 'you cannot ' + request[:action] + ' the adventure ' + @adventure.title
    end
  end
end
