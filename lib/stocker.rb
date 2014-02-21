#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'thor'
require 'titleize'

# @author Brandon Pittman
module Stocker
  class Generator < Thor
    trap("SIGINT") { exit 0 }

    @@path = nil

    private

    def self.check_for_dropbox
      home = Dir.home
      db = "#{Dir.home}/Dropbox"
      home_path = Pathname.new(home)
      db_path = Pathname.new(db)
      @@path = db_path || home_path
    end

    public

    check_for_dropbox
    #TODO: mv .stocker.yml .stocker.yaml if .stocker.yml exists
    @@yaml = Pathname.new("#{@@path}/.stocker.yaml")
    `touch #{@@yaml}`
    @@stock = YAML.load(@@yaml.read)
    @@stock = {} unless @@stock.class == Hash

    private

    def match_name(item)
      @@stock.each_key { |key| @@item = key if key =~ /#{item}/ }
    end

    public

    desc "new ITEM TOTAL", "Add ITEM with TOTAL on hand to inventory."
    option :url, :aliases => :u, :default => 'http://amazon.com'
    option :minimum, :aliases => :m, :default => 1
    def new(item, total)
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
          puts "You're running low on #{key}!"
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

    private

    def time(item)
      match_name(item)
      @@stock[@@item]["checked"] = Time.now
    end

    def self.save
      @@yaml.open('w') { |t| t << @@stock.to_yaml }
      # @@yaml.write(@@stock.to_yaml)
    end

    public

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
      invoke :check
    end

    desc "csv", "Write entire inventory as CSV."
    def csv
      @@stock.each { |key, value| puts "#{key.titlecase},#{value['total']},#{value['min']},#{value['url']},#{value['checked']}" }
    end

    desc "list", "List all inventory items and total on hand."
    long_desc <<-LONGDESC
      List outputs a colorized list of all your inventory items.

      Items that are well-stocked are green, items that are at the minimum acceptable will be yellow and out of stock items are red.

      The items are smartly organized by the difference between the 'on-hand' count and the minimum acceptable amount.

      example: I have 24 beers. I want to have at least 23 on hand at all times. I have 23 bags of chips, but I only need to have one at all times. The beer's difference is only one, but the chips' is 22. So even though I have more beer, it will show up below chips in the list.
    LONGDESC
    def list
      begin
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
      rescue Exception => e
        puts "Inventory empty"
      end
    end
  end
end