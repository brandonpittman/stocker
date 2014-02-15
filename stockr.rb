#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'thor'
require 'titleize'

class Stockr < Thor

  @@custom_path = '/Users/brandonpittman/Dropbox/Documents/Code/Ruby/inventory.yml'
  @@path = @@custom_path
  @@yaml = Pathname.new(@@path)
  @@stock = YAML.load(@@yaml.read)

  no_commands do
    def match_name(item)
      @@stock.each_key { |key| @@item = key if key =~ /#{item}/ }
    end
  end

  desc "add ITEM TOTAL", "Add ITEM with TOTAL on hand to inventory."
  option :url, :aliases => :u, :default => 'https://www.amazon.co.jp/gp/subscribe-and-save/manager/viewsubscriptions\?ie\=UTF8\&ref_\=ya_subscribe_and_save'
  option :min, :aliases => :m, :default => 1
  def add(item, total)
    @@stock[item] = {'total' => total.to_i, 'min' => options[:min].to_i, 'url' => options[:url], 'checked' => Time.now}
  end

  desc "delete ITEM", "Delete ITEM from inventory."
  def delete(item)
    match_name(item)
    @@stock.delete(@@item)
  end

  desc "check", "Check for low stock items."
  def check
    @@stock.each do |key, value|
      value["checked"] = Time.now
      if value["total"] <= value["min"]
        buy(key)
      end
    end
  end

  desc "total ITEM TOTAL", "Set TOTAL of ITEM."
  def total(item, total)
    match_name(item)
    @@stock[@@item]["total"] = total.to_i
    time(item)
  end

  no_commands do
    def time(item)
      match_name(item)
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
    match_name(item)
    @@stock[@@item]["url"] = url
    time(item)
  end

  desc "buy ITEM", "Open link to buy ITEM"
  def buy(item)
    match_name(item)
    `open -a Safari #{@@stock[@@item]["url"]}`
  end

  desc "min ITEM MINIMUM", "Set minimum acceptable amount for ITEM."
  def min(item, min)
    match_name(item)
    @@stock[@@item]["min"] = min.to_i
  end

  desc "count", "Take an interactive inventory."
  def count
    @@stock.each do |key, value|
      value["checked"] = Time.now
      value["total"] = ask("#{key.titlecase}:", *args).to_i
    end
  end

  desc "csv", "Write entire inventory to STred as CSV."
  def csv
    @@stock.each { |key, value| puts "#{key.titlecase},#{value['total']},#{value['min']},#{value['url']},#{value['checked']}" }
  end

  desc "list", "List all inventory items and total on hand."
  def list
    @header = [[set_color("Item", :white), set_color("Total", :white)], [set_color("=================", :white), set_color("=====", :white)]]
    @green = []
    @yellow = []
    @yellow2 = []
    @green2 = []
    @red = []
    @red2 = []
    @@stock.each do |key, value|
      if value['total'] > value['min']
        @green += [[key.titlecase,value['total'], value['total']-value['min']]]
      elsif value['total'] == value['min']
        @yellow += [[key.titlecase,value['total'], value['total']-value['min']]]
      else
        @red += [[key.titlecase,value['total'], value['total']-value['min']]]
      end
    end
    @green.sort_by! { |a,b,c| c }
    @yellow.sort_by! { |a,b,c| c }
    @red.sort_by! { |a,b,c| c }
    @green.reverse!
    @yellow.reverse!
    @red.reverse!
    @green.each { |a,b| @green2 += [[set_color(a, :green), set_color(b, :green)]] }
    @yellow.each { |a,b| @yellow2 += [[set_color(a, :yellow), set_color(b, :yellow)]] }
    @red.each { |a,b| @red2 += [[set_color(a, :red), set_color(b, :red)]] }
    print_table(@header + @green2 + @yellow2 + @red2,{indent: 2})
  end
end

Stockr.start(ARGV)
Stockr.save
