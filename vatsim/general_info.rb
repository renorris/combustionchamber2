require_relative 'vatsim_data_container'

# General network info
class GeneralInfo < VatsimDataContainer

  attr_reader :version, :reload, :update, :update_timestamp, :connected_clients, :unique_users

  def initialize(version, reload, update, update_timestamp, connected_clients, unique_users)
    @version = clean_str_for_discord(version)
    @reload = clean_str_for_discord(reload)
    @update = clean_str_for_discord(update)
    @update_timestamp = clean_str_for_discord(update_timestamp)
    @connected_clients = clean_str_for_discord(connected_clients)
    @unique_users = clean_str_for_discord(unique_users)
  end

  def self.from_hash(hash)
    if hash.nil?
      return nil
    end

    GeneralInfo.new(hash['verison'], hash['reload'], hash['update'], hash['update_timestamp'], hash['connected_clients'], hash['unique_users'])
  end
end