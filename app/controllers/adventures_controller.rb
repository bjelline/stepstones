class AdventuresController < ApplicationController
  before_filter :find_adventure, :only => [ :show, :edit, :update, :destroy ]

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

  # POST /adventures
  # POST /adventures.json
  def create
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
    @adventure = Adventure.includes(:steps).find(params[:id])
  end
end
