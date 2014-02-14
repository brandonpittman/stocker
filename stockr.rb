#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'thor'
require 'titleize'

class Stockr < Thor
  @@custom_path = '/Users/brandonpittman/Dropbox/Documents/Code/Ruby/inventory.yml'
  @@path = @@custom_path || fallback_path
  @@yaml = Pathname.new(@@path)
  @@stock = YAML.load(@@yaml.read)

  no_commands do
    def self.match_name(item)
      @@stock.each_key { |key| @@item = key if key =~ /#{item}/ }
    end
  end

  no_commands do
    def self.fallback_path
    `touch #{Dir.home}/.inventory.yml`
    @@path = "#{Dir.home}/.inventory.yml"
    end
  end

  desc "add ITEM TOTAL", "Add ITEM with TOTAL on hand to inventory."
  option :url, :aliases => :u, :default => 'http://www.amazon.co.jp'
  option :min, :aliases => :m, :default => 1
  def add(item, total)
    @@stock[item] = {'total' => total.to_i, 'min' => options[:min].to_i, 'url' => options[:url], 'checked' => Time.now}
  end

  desc "delete ITEM", "Delete ITEM from inventory."
  def delete(item)
    Stockr.match_name(item)
    @@stock.delete(@@item)
  end

  desc "check", "Check for low stock items."
  def check
    @@stock.each do |key, value|
      value["checked"] = Time.now
      if value["total"] <= value["min"]
        puts "You need to buy more #{key}!"
        buy(key)
      end
    end
  end

  desc "total ITEM TOTAL", "Set TOTAL of ITEM."
  def total(item, total)
    Stockr.match_name(item)
    @@stock[@@item]["total"] = total.to_i
    Stockr.time(item)
  end

  no_commands do
    def self.time(item)
      Stockr.match_name(item)
      @@stock[@@item]["checked"] = Time.now
    end
  end

  no_commands do
    def self.save
      @@yaml.write(@@stock.to_yaml)
    end
  end

  desc "url ITEM URL", "Set URL of ITEM."
  def url(item, url)
    Stockr.match_name(item)
    @@stock[@@item]["url"] = url
    Stockr.time(item)
  end

  desc "buy ITEM", "Open link to buy ITEM"
  def buy(item)
    Stockr.match_name(item)
    `open -a Safari #{@@stock[@@item]["url"]}`
  end

  desc "min ITEM MINIMUM", "Set minimum acceptable amount for ITEM."
  def min(item, min)
    Stockr.match_name(item)
    @@stock[@@item]["min"] = min.to_i
  end

  desc "count", "Take an interactive inventory."
  def count
    @@stock.each do |key, value|
      value["checked"] = Time.now
      value["total"] = ask("Enter total for #{key}:", *args).to_i
    end
  end

  desc "list", "List all inventory items and total on hand."
  def list
    @array = [['Item', 'Total'],['====================','=====']]
    @@stock.each do |key, value|
      @array += [[key.titlecase,value['total']]]
    end
    print_table(@array,{indent: 2})
  end
end

Stockr.start(ARGV)
Stockr.save
