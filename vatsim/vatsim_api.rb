require 'net/http'
require 'json'

require_relative 'vatsim_data_container'
require_relative 'general_info'
require_relative 'pilot_details'
require_relative 'flight_plan'
require_relative 'controller_details'

class VatsimAPI

  def initialize
    @data = {}
    @callsign_to_pilot_hash = {}
    @callsign_to_controller_hash = {}
    @semaphore = Mutex.new

    @json3_uri = ''
    Net::HTTP.get(URI('https://status.vatsim.net/')).each_line do |line|
      if line.start_with? 'json3'
        @json3_uri = line.split('=')[1].chomp
      end
    end

    # Download initial data
    download_data
    @time_downloaded = Time.now
  end

  def should_download?
    Time.now - @time_downloaded > 60
  end

  def download_data
    puts "[VATSIM API] Downloading data..."
    # Download data
    @data = JSON.parse(Net::HTTP.get(URI(@json3_uri)))

    # Write callsign-to-pilot hash
    @callsign_to_pilot_hash = {}
    @data['pilots'].each do |pilot|
      @callsign_to_pilot_hash[pilot['callsign']] = pilot
    end

    # Write callsign-to-controller hash
    @callsign_to_controller_hash = {}
    @data['controllers'].each do |controller|
      @callsign_to_controller_hash[controller['callsign']] = controller
    end

    # Reset time downloaded
    @time_downloaded = Time.now

    puts "[VATSIM API] Done."
  end

  def general_network_info
    general_info = 0
    @semaphore.synchronize do
      should_download? ? download_data : nil
      @data['general'].nil? ? general_info = nil : general_info = GeneralInfo.from_hash(@data['general'])
    end
    general_info
  end

  def aircraft_details(callsign)
    aircraft_details = 0
    @semaphore.synchronize do
      should_download? ? download_data : nil
      aircraft_details = PilotDetails.from_hash(@callsign_to_pilot_hash[callsign])
    end
    aircraft_details
  end

  def aircraft_departing_from(icaocode)
    icaocode = icaocode.upcase
    aircraft_list = []
    @semaphore.synchronize do
      should_download? ? download_data : nil
      @data['pilots'].each do |pilot|
        aircraft_details = PilotDetails.from_hash(pilot)
        unless aircraft_details.flight_plan.nil?
          if aircraft_details.flight_plan.departure == icaocode
            aircraft_list.push aircraft_details
          end
        end
      end
    end
    aircraft_list == [] ? nil : aircraft_list
  end

  def aircraft_arriving_to(icaocode)
    icaocode = icaocode.upcase
    aircraft_list = []
    @semaphore.synchronize do
      should_download? ? download_data : nil
      @data['pilots'].each do |pilot|
        aircraft_details = PilotDetails.from_hash(pilot)
        unless aircraft_details.flight_plan.nil?
          if aircraft_details.flight_plan.arrival == icaocode
            aircraft_list.push aircraft_details
          end
        end
      end
    end
    aircraft_list == [] ? nil : aircraft_list
  end

  def controller_details(callsign)
    controller_details = 0
    @semaphore.synchronize do
      should_download? ? download_data : nil
      controller_details = ControllerDetails.from_hash(@callsign_to_controller_hash[callsign])
    end
    controller_details
  end
end
