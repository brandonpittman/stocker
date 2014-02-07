#!/usr/bin/env ruby

require 'pathname'
require 'yaml'

@yaml = Pathname.new('/Users/user/inventory.yml')
@stock = YAML.load(@yaml.read)
@command = ARGV.shift
@item = ARGV.shift
if ARGV[0].to_i > 0
  @amount = ARGV.shift.to_i
  @link = ARGV.shift
else
  @link = ARGV.shift
end

def new_item
  unless @stock.include?(@item)
    @stock[@item] = {total: @amount, quota: 1, link: @link, checked: Time.now}
  end
end

def delete
  if @stock.include?(@item)
    @stock.delete(@item)
  end
end

def check
  @stock.each do |key, value|
    value["checked"] = Time.now
    @stock_low = 0
    if value["total"] <= value["quota"]
      puts "You need to buy more #{key}!" 
      @stock_low = @stock_low += 1
    end
  end
  puts "You're fully stocked!" unless @stock_low > 0
end

def total
  puts @stock[@item]["total"]
  @stock[@item]["checked"] = Time.now
end

def add
  @stock[@item]["total"] += @amount
end

def subtract
  @stock[@item]["total"] -= @amount
end

def save
  @yaml.write(@stock.to_yaml)
end

def link
  @stock[@item]["link"] = @link
end

def buy
  `open -a Safari #{@stock[@item]["link"]}`
end

case @command
  when 'add' then add
  when 'subtract' then subtract
  when 'total' then total
  when 'new' then new_item
  when 'delete' then delete
  when 'check' then check
  when 'buy' then buy
  when 'link' then link
end

save
