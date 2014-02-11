#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'optparse'

@yaml = Pathname.new('/Users/brandonpittman/Dropbox/Documents/Code/Ruby/inventory.yml')
@stock = YAML.load(@yaml.read)

options = {}
OptionParser.new do |opts|
  opts.banner = "    Manage an inventory at home or work.

    Usage: stockr [options]

"

  opts.on("-n NAME", "--new NAME", "Name of inventory item.") do |name|
    @item_name = options[:name] = name
  end
  opts.on("-d", "--delete", "Deletes an inventory item.") do |delete|
    @delete = options[:delete] = delete
  end
  opts.on("-a AMOUNT", "--add AMOUNT", "Adds a new inventory item.") do |amount|
    @add = options[:add] = amount.to_i
  end
  opts.on("-c", "--check", "Checks for out of stock inventory items.") do |check|
    @check = options[:check] = check
  end
  opts.on("-t AMOUNT", "--total AMOUNT", "Sets total of an inventory item.") do |amount|
    @total = options[:total] = amount.to_i
  end
  opts.on("-u URL", "--url URL", "Sets URL of an inventory item.") do |url|
    @url = options[:url] = url
  end
  opts.on("-m AMOUNT", "--min AMOUNT", "Sets the minimum acceptable amount of an inventory item.") do |min|
    @min = options[:min] = min.to_i
  end
  opts.on("-b", "--buy", "Opens URL of an inventory item.") do |buy|
    @buy = options[:buy] = buy
  end
end.parse!

@stock.each_key { |key| @item = key if key =~ /#{@item_name}/ }

def add
  @stock[@item_name] = {total: @add, min: 1, url: @url, checked: Time.now} unless @stock.include?(@item)
end

def delete
  @stock.delete(@item)
end

def check
  @stock.each do |key, value|
    value["checked"] = Time.now
    if value["total"] <= value["min"]
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

def min
  @stock[@item]["min"] = @min
end

def help
  p "This is the help message." if @help
end

check if @check
url if @url
total if @total
delete if @delete
add if @add
min if @min
help if @help
save
