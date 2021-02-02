#!/usr/bin/env ruby

require 'discordrb'
require 'yaml'

require_relative 'vatsim_command_handler'

bot = Discordrb::Commands::CommandBot.new token: File.read('token.txt'), prefix: ';', command_doesnt_exist_message: "Unknown command"
cmd_usages = YAML.load(File.read "command_usages.yml")
vatsim_command_handler = VatsimCommandHandler.new

bot.command(:random, min_args: 2, description: "Returns a random value between two provided arguments", usage: cmd_usages['random']) do |event, min, max|
  rand(min.to_i .. max.to_i)
end

bot.command(:vatsim, description: "VATSIM-specific commands", usage: cmd_usages['vatsim']) do |event|
  vatsim_command_handler.handle(event)
end

bot.run