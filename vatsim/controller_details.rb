require_relative 'vatsim_data_container'

# Controller details
class ControllerDetails < VatsimDataContainer

  attr_reader :cid, :name, :callsign, :frequency, :facility, :rating, :server, :visual_range, :text_atis, :last_updated, :logon_time

  def initialize(cid,
                 name,
                 callsign,
                 frequency,
                 facility,
                 rating,
                 server,
                 visual_range,
                 text_atis,
                 last_updated,
                 logon_time)
    @cid = clean_str_for_discord(cid)
    @name = clean_str_for_discord(name)
    @callsign = clean_str_for_discord(callsign)
    @frequency = clean_str_for_discord(frequency)
    @facility = clean_str_for_discord(facility)
    @rating = clean_str_for_discord(rating)
    @server = clean_str_for_discord(server)
    @visual_range = clean_str_for_discord(visual_range)

    if text_atis.nil? || text_atis == []
      @text_atis = 'unknown'
    else
      @text_atis = ''
      text_atis.each do |line|
        @text_atis << line.to_s + "\n"
      end
    end

    @last_updated = clean_str_for_discord(last_updated)
    @logon_time = clean_str_for_discord(logon_time)
  end

  def self.from_hash(hash)
    if hash.nil?
      return nil
    end

    ControllerDetails.new(hash['cid'],
                          hash['name'],
                          hash['callsign'],
                          hash['frequency'],
                          hash['facility'],
                          hash['rating'],
                          hash['server'],
                          hash['visual_range'],
                          hash['text_atis'],
                          hash['last_updated'],
                          hash['logon_time'])
  end
end