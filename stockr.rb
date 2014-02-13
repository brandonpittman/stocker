#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'thor'

class Stockr < Thor
  
  no_commands do
    def self.fallback_path
    `touch #{Dir.home}/.inventory.yml`
    @@path = "#{Dir.home}/.inventory.yml"
    end
  end
  
  @@custom_path = ''
  @@path = @@custom_path || fallback_path
  @@yaml = Pathname.new(@@path)
  @@stock = YAML.load(@@yaml.read)

  desc "add ITEM", "Add ITEM to inventory."
  option :url, :aliases => :u, :required => true
  option :total, :aliases => :t, :required => true
  option :min, :aliases => :m, :default => 1
  def add(item)
    @@stock[item] = {'total' => options[:total].to_i, 'min' => options[:min].to_i, 'url' => options[:url], 'checked' => Time.now}
    Stockr.save
  end

  desc "delete ITEM", "Delete ITEM from inventory."
  def delete(item)
    @@stock.each_key { |key| @item_name = key if key =~ /#{item}/ }
    @@stock.delete(@item_name)
    Stockr.save
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
    Stockr.save
  end

  desc "total ITEM TOTAL", "Set TOTAL of ITEM."
  def total(item, total)
    @@stock[item]["total"] = total.to_i
    Stockr.time(item)
    Stockr.save
  end

  no_commands do
    def self.time(item)
      @@stock[item]["checked"] = Time.now
    end
  end

  no_commands do
    def self.save
      @@yaml.write(@@stock.to_yaml)
    end
  end

  desc "url ITEM URL", "Set URL of ITEM."
  def url(item, url)
    @@stock[item]["url"] = url
    Stockr.time(item)
    Stockr.save
  end

  desc "buy ITEM", "Open link to buy ITEM"
  def buy(item)
    `open -a Safari #{@@stock[item]["url"]}`
  end

  desc "min ITEM MINIMUM", "Set minimum acceptable amount for ITEM."
  def min(item, min)
    @@stock[item]["min"] = min.to_i
    Stockr.save
  end

  desc "count", "Take an interactive inventory."
  def count
    @@stock.each do |key, value|
      value["checked"] = Time.now
      value["total"] = ask("Enter total for #{key}:", *args).to_i
    end
    Stockr.save
  end
end

Stockr.start(ARGV)
