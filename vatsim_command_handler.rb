require_relative 'vatsim/vatsim_api'

class VatsimCommandHandler
  def initialize
    @vatsim_api = VatsimAPI.new
  end

  def handle(event)
    args = event.content.split(' ')[1..-1]

    case args[0]
    when 'info'
      info(event)
    when 'aircraft'
      aircraft(event, args)
    when 'departures'
      departures(event, args)
    when 'arrivals'
      arrivals(event, args)
    when 'controller'
      controller(event, args)
    else
      event.channel.send_message 'Invalid arguments, see `;help vatsim`'
    end
  end

  def send_embed(event, &event_def)
    event.channel.send_embed('') do |embed|
      event_def.call(embed)
    end
  end

  def info(event)
    general_info = @vatsim_api.general_network_info
    if general_info.nil?
      event.channel.send_message '[ERROR] Server info not found! This is either a bug or the VATSIM API is broken.'
      return
    end
    send_embed(event) do |embed|
      embed.colour = '#00FF00'
      embed.title = 'VATSIM Info'
      embed.add_field(name: 'Updated At', value: general_info.update_timestamp, inline: false)
      embed.add_field(name: 'Connected Clients', value: general_info.connected_clients, inline: false)
      embed.add_field(name: 'Unique Users', value: general_info.unique_users, inline: false)
    end
  end

  def aircraft(event, args)
    if args[1].nil?
      event.channel.send_message 'Invalid arguments, see `;help vatsim`'
      return
    end

    aircraft_details = @vatsim_api.aircraft_details(args[1])
    if aircraft_details.nil?
      event.channel.send_message "No aircraft was found with the callsign `#{args[1]}`"
      return
    end

    send_embed(event) do |embed|
      embed.colour = '#00FF00'
      embed.title = aircraft_details.callsign
      embed.add_field(name: 'Pilot', value: aircraft_details.name, inline: true)
      embed.add_field(name: 'CID', value: "[#{aircraft_details.cid}](https://vatstats.net/pilots/#{aircraft_details.cid})", inline: true)
      embed.add_field(name: 'Location', value: "[#{aircraft_details.latitude}, #{aircraft_details.longitude}](https://skyvector.com/?ll=#{aircraft_details.latitude},#{aircraft_details.longitude}&chart=301&zoom=4)", inline: true)
      embed.add_field(name: 'Altitude', value: aircraft_details.altitude, inline: true)
      embed.add_field(name: 'Groundspeed', value: aircraft_details.groundspeed, inline: true)
      embed.add_field(name: 'Heading', value: aircraft_details.heading, inline: true)

      unless aircraft_details.flight_plan.nil?
        flight_plan = aircraft_details.flight_plan
        embed.add_field(name: 'Flight Plan', value: '↓', inline: false)

        case flight_plan.flight_rules
        when 'I'
          flight_rules_str = 'IFR'
        when 'V'
          flight_rules_str = 'VFR'
        else
          flight_rules_str = flight_plan.flight_rules
        end
        embed.add_field(name: 'Flight Rules', value: flight_rules_str, inline: true)

        embed.add_field(name: 'Aircraft', value: flight_plan.aircraft, inline: true)
        embed.add_field(name: 'Departure', value: "[#{flight_plan.departure}](https://skyvector.com/airport/#{flight_plan.departure})", inline: true)
        embed.add_field(name: 'Arrival', value: "[#{flight_plan.arrival}](https://skyvector.com/airport/#{flight_plan.arrival})", inline: true)
        embed.add_field(name: 'Alternate', value: "[#{flight_plan.alternate}](https://skyvector.com/airport/#{flight_plan.alternate})", inline: true)
        embed.add_field(name: 'Filed TAS', value: flight_plan.cruise_tas, inline: true)
        embed.add_field(name: 'Filed Altitude', value: flight_plan.altitude, inline: true)
        embed.add_field(name: 'Departure Time', value: flight_plan.deptime, inline: true)
        embed.add_field(name: 'Enroute Time', value: flight_plan.enroute_time, inline: true)
        embed.add_field(name: 'Fuel Time', value: flight_plan.fuel_time, inline: true)

        # https://skyvector.com/?&chart=301&fpl=%20KSAN%20ZZOOO%20MZB%20KLAX
        skyvector_link = 'https://skyvector.com/?&chart=301&fpl=%20'
        skyvector_link << flight_plan.departure + '%20'
        skyvector_link << flight_plan.route.gsub(' ', '%20') + '%20'
        skyvector_link << flight_plan.arrival

        embed.add_field(name: 'Route', value: "[#{flight_plan.route}](#{skyvector_link})", inline: true)
        embed.add_field(name: 'Remarks', value: flight_plan.remarks, inline: true)
      end
    end
  end

  def departures(event, args)
    if args[1].nil?
      event.channel.send_message 'Invalid arguments, see `;help vatsim`'
      return
    end
    icaocode = args[1].upcase
    aircraft_list = @vatsim_api.aircraft_departing_from(icaocode)
    if aircraft_list.nil?
      event.channel.send_message "No departures found for `#{icaocode}`"
      return
    end
    send_embed(event) do |embed|
      embed.colour = '#00FF00'
      embed.title = "#{icaocode} Departures"
      aircraft_list_str = ''
      aircraft_list.each_with_index do |pilot, i|
        unless i == 0
          aircraft_list_str << ', '
        end
        aircraft_list_str << pilot.callsign
      end
      embed.add_field(name: 'Aircraft', value: aircraft_list_str, inline: true)
    end
  end

  def arrivals(event, args)
    if args[1].nil?
      event.channel.send_message 'Invalid arguments, see `;help vatsim`'
      return
    end
    icaocode = args[1].upcase
    aircraft_list = @vatsim_api.aircraft_arriving_to(icaocode)
    if aircraft_list.nil?
      event.channel.send_message "No arrivals found for `#{icaocode}`"
      return
    end
    send_embed(event) do |embed|
      embed.colour = '#00FF00'
      embed.title = "#{icaocode} Arrivals"
      aircraft_list_str = ''
      aircraft_list.each_with_index do |pilot, i|
        unless i == 0
          aircraft_list_str << ', '
        end
        aircraft_list_str << pilot.callsign
      end
      embed.add_field(name: 'Aircraft', value: aircraft_list_str, inline: true)
    end
  end

  def controller(event, args)
    if args[1].nil?
      event.channel.send_message 'Invalid arguments, see `;help vatsim`'
      return
    end

    controller_details = @vatsim_api.controller_details(args[1])
    if controller_details.nil?
      event.channel.send_message "No controller was found with the callsign `#{args[1]}`"
      return
    end

    send_embed(event) do |embed|
      embed.colour = '#00FF00'
      embed.title = controller_details.callsign
      embed.add_field(name: 'Controller', value: controller_details.name, inline: true)
      embed.add_field(name: 'CID', value: "[#{controller_details.cid}](https://vatstats.net/pilots/#{controller_details.cid})", inline: true)
      embed.add_field(name: 'Frequency', value: controller_details.frequency, inline: true)
      embed.add_field(name: 'Facility', value: controller_details.facility, inline: true)
      embed.add_field(name: 'Rating', value: controller_details.rating, inline: true)
      embed.add_field(name: 'Range', value: "#{controller_details.visual_range}nm", inline: true)
      embed.add_field(name: 'Server', value: controller_details.server, inline: true)
      embed.add_field(name: 'ATIS', value: controller_details.text_atis, inline: true)
    end
  end
end