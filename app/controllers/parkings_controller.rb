class ParkingsController < ApplicationController
  before_action :set_parking, only: [:show, :update, :destroy]

  # GET /parkings
  def index
    @parkings = Parking.all

    render json: @parkings
  end

  # GET /parkings/1
  def show
    render json: @parking
  end

  # POST /parkings
  def create
    
    if Parking.find_by(plate:parking_params["plate"], left:false)
      return render json: {error:"Parked vehicle"}, status: :bad_request
    end
    
    if validate(parking_params["plate"])
      @parking = Parking.new(
        plate:parking_params["plate"],
        entrance:Time.current,
        left:false,
        pay:false)
  
      if @parking.save
        render json: @parking, only: [:id], status: :created, location: @parking
      else
        render json: @parking.errors, status: :unprocessable_entity
      end
    else
      render json: {error:"Plate is not valid"}, status: :bad_request
    end
  end

  # PATCH/PUT /parkings/1
  def update
    if @parking.update(parking_params)
      render json: @parking
    else
      render json: @parking.errors, status: :unprocessable_entity
    end
  end

  # DELETE /parkings/1
  def destroy
    @parking.destroy
  end
  
  # GET /parking/:plate/
  def plate
    r = []
    Parking.where(plate:params[:plate]).map{
      |p| r.push(id:p.id, time:(p.left ? "#{((p.departure-p.entrance)/60).round(1)} minutes" : "parked"),paid:(p.pay?), left:p.left?)
    }
    
    render json: r
  end
  
  # PUT /parking/:id/pay/
  def pay
    
    unless Parking.exists?(id:params[:id])
      return render json: {error:"no parked"}, status: :bad_request
    end
    
    if Parking.exists?(id:params[:id], pay:true)
      return render json: {error:"it has been paid"}, status: :bad_request
    end
    
    @parking = Parking.update(params[:id], pay:true)
      render json: @parking

  end
  
  def out
    
    unless Parking.exists?(id:params[:id])
      return render json: {error:"non parked vehicle"}, status: :bad_request
    end
    
    if Parking.exists?(id:params[:id], left:true)
      return render json: {error:"vehicle has already left"}, status: :bad_request
    end
    
    if (Parking.find(params[:id]).pay)
      @parking = Parking.update(params[:id], left:true, departure:Time.current)
      render json: @parking
    else
      render json: {error:"pending payment"}, status: :payment_required
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parking
      @parking = Parking.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def parking_params
      params.require(:parking).permit(:plate, :entrance, :departure, :pay, :left)
    end
    
    def paid(pay)
      if pay
        true
      else
        false
      end
    end
    
    def isNumber(number)
        true if Integer(number) rescue false
    end
    
    def validate(plate)
      if parking_params["plate"].index('-')==3
      p1,p2 = parking_params["plate"].split('-')
        if p1.size==3 and p2.size==4
          if p1.scan(/\d/).size==0 and isNumber(p2)
            true
          end
        end
      end
    end
    
end
