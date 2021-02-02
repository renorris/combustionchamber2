require_relative 'vatsim_data_container'

# Flight Plan for pilot
class FlightPlan < VatsimDataContainer

  attr_reader :flight_rules, :aircraft, :departure, :arrival, :alternate, :cruise_tas, :altitude, :deptime, :enroute_time, :fuel_time, :remarks, :route

  def initialize(flight_rules,
                 aircraft,
                 departure,
                 arrival,
                 alternate,
                 cruise_tas,
                 altitude,
                 deptime,
                 enroute_time,
                 fuel_time,
                 remarks,
                 route)
    @flight_rules = clean_str_for_discord(flight_rules)
    @aircraft = clean_str_for_discord(aircraft)
    @departure = clean_str_for_discord(departure)
    @arrival = clean_str_for_discord(arrival)
    @alternate = clean_str_for_discord(alternate)
    @cruise_tas = clean_str_for_discord(cruise_tas)
    @altitude = clean_str_for_discord(altitude)
    @deptime = clean_str_for_discord(deptime)
    @enroute_time = clean_str_for_discord(enroute_time)
    @fuel_time = clean_str_for_discord(fuel_time)
    @remarks = clean_str_for_discord(remarks)
    @route = clean_str_for_discord(route)
  end

  def self.from_hash(hash)
    if hash.nil?
      return nil
    end

    FlightPlan.new(hash['flight_rules'],
                     hash['aircraft'],
                     hash['departure'],
                     hash['arrival'],
                     hash['alternate'],
                     hash['cruise_tas'],
                     hash['altitude'],
                     hash['deptime'],
                     hash['enroute_time'],
                     hash['fuel_time'],
                     hash['remarks'],
                     hash['route'])
  end
end