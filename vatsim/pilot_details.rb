require_relative 'vatsim_data_container'
require_relative 'flight_plan'

# Pilot details
class PilotDetails < VatsimDataContainer

  attr_reader :cid, :name, :callsign, :server, :pilot_rating, :latitude, :longitude, :altitude, :groundspeed, :transponder, :heading, :qnh_i_hg, :qnh_mb, :flight_plan, :logon_time, :last_updated

  def initialize(cid,
                 name,
                 callsign,
                 server,
                 pilot_rating,
                 latitude,
                 longitude,
                 altitude,
                 groundspeed,
                 transponder,
                 heading,
                 qnh_i_hg,
                 qnh_mb,
                 flight_plan,
                 logon_time,
                 last_updated)
    @cid = clean_str_for_discord(cid)
    @name = clean_str_for_discord(name)
    @callsign = clean_str_for_discord(callsign)
    @server = clean_str_for_discord(server)
    @pilot_rating = clean_str_for_discord(pilot_rating)
    @latitude = clean_str_for_discord(latitude)
    @longitude = clean_str_for_discord(longitude)
    @altitude = clean_str_for_discord(altitude)
    @groundspeed = clean_str_for_discord(groundspeed)
    @transponder = clean_str_for_discord(transponder)
    @heading = clean_str_for_discord(heading)
    @qnh_i_hg = clean_str_for_discord(qnh_i_hg)
    @qnh_mb = clean_str_for_discord(qnh_mb)
    @flight_plan = FlightPlan.from_hash(flight_plan)
    @logon_time = clean_str_for_discord(logon_time)
    @last_updated = clean_str_for_discord(last_updated)
  end

  def self.from_hash(hash)
    if hash.nil?
      return nil
    end

    PilotDetails.new(hash['cid'],
                     hash['name'],
                     hash['callsign'],
                     hash['server'],
                     hash['pilot_rating'],
                     hash['latitude'],
                     hash['longitude'],
                     hash['altitude'],
                     hash['groundspeed'],
                     hash['transponder'],
                     hash['heading'],
                     hash['qnh_i_hg'],
                     hash['qnh_mb'],
                     hash['flight_plan'],
                     hash['logon_time'],
                     hash['last_updated'])
  end
end