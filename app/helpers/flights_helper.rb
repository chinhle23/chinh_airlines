module FlightsHelper
  def flight_params
    params.require(:flight).permit(:origin, :destination, :price)
  end
end
