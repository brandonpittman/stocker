#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'optparse'

@yaml = Pathname.new("#{Dir.home}/.inventory.yml")
@stock = YAML.load(@yaml.read)

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: stockr [options]"

  opts.on("-n NAME", "--new NAME", "new NAME") do |name|
    @item_name = options[:name] = name
  end
  opts.on("-d", "--delete", "delete") do |delete|
    @delete = options[:delete] = delete
  end
  opts.on("-a AMOUNT", "--add AMOUNT", "add AMOUNT") do |amount|
    @add = options[:add] = amount.to_i
  end
  opts.on("-c", "--check", "check") do |check|
    @check = options[:check] = check
  end
  opts.on("-t AMOUNT", "--total AMOUNT", "total AMOUNT") do |amount|
    @total = options[:total] = amount.to_i
  end
  opts.on("-u URL", "--url URL", "url URL") do |url|
    @url = options[:url] = url
  end
  opts.on("-l AMOUNT", "--limit AMOUNT", "limit AMOUNT") do |limit|
    @limit = options[:limit] = limit.to_i
  end
  opts.on("-b", "--buy", "buy") do |buy|
    @buy = options[:buy] = buy
  end
  opts.on("-h", "--help", "help") do |help|
    @help = options[:help] = help
  end
end.parse!

@stock.each_key { |key| @item = key if key =~ /#{@item_name}/ }

def add
  @stock[@item_name] = {total: @add, limit: 1, link: @link, checked: Time.now} unless @stock.include?(@item)
end

def delete
  @stock.delete(@item)
end

def check
  @stock.each do |key, value|
    value["checked"] = Time.now
    if value["total"] <= value["limit"]
      puts "You need to buy more #{key}!"
      order(key)
    end
  end
end

def total
  @stock[@item]["total"] = @total
  time
end

def time
  @stock[@item]["checked"] = Time.now
end

def save
  @yaml.write(@stock.to_yaml)
end

def url
  @stock[@item]["url"] = @url
  time
end

def order(item)
  `open -a Safari #{@stock[item]["url"]}`
end

def help
  p "This is the help message." if @help
end

check if @check
url if @url
total if @total
delete if @delete
add if @add
help if @help
save
