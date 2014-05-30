#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'thor'
require 'titleize'

# Stocker is an app for managing an inventory of items. For example, an inventory of household items such as cleaning products, foodstuffs and how many bottles of beer you have.
# @author Brandon Pittman
module Stocker
  # This is the "God" object that interacts with Thor's methods.
  class Generator < Thor
    # This trap is so that if you <Ctrl-C> out of "Stocker#count" your terminal won't display an error.
    trap("SIGINT") { exit 0 }

    desc "new ITEM TOTAL", "Add ITEM with TOTAL on hand to inventory."
    option :url, :aliases => :u
    option :minimum, :aliases => :m, :default => 1
    # Creates a new item in the inventory
    # @param item [String] The item to add to the inventory
    # @param total [String] How many of the new item on hand
    # @return [Hash] Returns a hash of the updated inventory and writes YAML to .stocker.yaml
    def new(item, total)
        data = read_file
        data[item] = {'total' => total.to_i, 'min' => options[:minimum].to_i, 'url' => options[:url] || read_config['url'], 'checked' => Time.now}
        write_file(data)
    end

    desc "delete ITEM", "Delete ITEM from inventory."
    # Deletes an item from the inventory.
    # Stocker will attempt a "fuzzy match" of the item name.
    # @param item [String] The item to delete from the inventory
    # @return [Hash] Returns a hash of the updated inventory and writes YAML to .stocker.yaml
    def delete(item)
      data = read_file
      match_name(item)
      data.delete(@@item)
      write_file(data)
    end

    desc "check", "Check for low stock items."
    # Checks the total number of items on hand against their acceptable minimum values and opens the URLs of any items running low in stock.
    # @return Opens a link in default web browser if URL is set for low stock item
    def check
      links = []
      read_file.each do |key, value|
        value["checked"] = Time.now
        if value["total"] < value["min"]
          puts "You're running low on #{key}!"
          links << key
        end
      end
      links.uniq!
      links.each { |link| buy(link)}
    end

    desc "total ITEM TOTAL", "Set TOTAL of ITEM."
    # Set total of existing item in Stocker's inventory
    # @param item [String] item to update
    # @param total [String] total on hand
    def total(item, total)
      data = read_file
      match_name(item)
      data[@@item]["total"] = total.to_i
      time(item)
      write_file(data)
    end

    desc "url ITEM URL", "Set URL of ITEM."
    # Set URL of existing item in Stocker's inventory
    # @param item [String] item to update
    # @param url [String] URL of item
    def url(item, url)
      data = read_file
      match_name(item)
      data[@@item]["url"] = url
      time(item)
      write_file(data)
    end

    desc "buy ITEM", "Open link to buy ITEM"
    # Open URL of item
    # @param item [String] existing item in inventory
    def buy(item)
      match_name(item)
      `open -a Safari #{read_file[@@item]["url"]}`
    end

    desc "min ITEM MINIMUM", "Set minimum acceptable amount for ITEM."
    # Set minimum acceptable amount of existing inventory item
    # @param item [String] item to update
    # @param min [String] acceptable minimum amount of item to always have on hand
    def min(item, min)
      data = read_file
      match_name(item)
      data[@@item]["min"] = min.to_i
      write_file(data)
    end

    desc "count", "Take an interactive inventory."
    # Do a count update for all inventory items *interactively*.
    # Stocker#count will loop through the inventory and ask you for the total on hand count for each item.
    # When the counting is finished, Stocker will run Stocker#check and open the URLs of any low stock items.
    def count
      values = read_file
      values.each do |key, value|
        value["checked"] = Time.now
        value["total"] = ask("#{key.titlecase}:").to_i
      end
      write_file(values)
      invoke :check
    end

    desc "csv", "Write entire inventory as CSV."
    # Output a CSV dump of the entire inventory. This is useful with `awk` and `sed`.
    # @return [String] CSV of entire inventory
    def csv
      read_file.each { |key, value| puts "#{key.titlecase},#{value['total']},#{value['min']},#{value['url']},#{value['checked']}" }
    end

    desc "list", "List all inventory items and total on hand."
    long_desc <<-LONGDESC
      List outputs a colorized list of all your inventory items.

      Items that are well-stocked are green, items that are at the minimum acceptable will be yellow and out of stock items are red.

      The items are smartly organized by the difference between the 'on-hand' count and the minimum acceptable amount.

      example: I have 24 beers. I want to have at least 23 on hand at all times. I have 23 bags of chips, but I only need to have one at all times. The beer's difference is only one, but the chips' is 22. So even though I have more beer, it will show up below chips in the list.
    LONGDESC
    # Print a list of all inventory items. Green items are well stocked. Yellow items are at minimum acceptable total. Red items are below minimum acceptable total.
    def list
      begin
        @header = [[set_color("Item", :white), set_color("Total", :white)], [set_color("=================", :white), set_color("=====", :white)]]
        @green = []
        @yellow = []
        @yellow2 = []
        @green2 = []
        @red = []
        @red2 = []
        read_file.each do |key, value|
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

    desc "config", "Set configuration settings for stocker."
    option :url, :aliases => :u, :type => :string, :required => true
    # Configure Stocker's default settings
    # If the --url param is not passed, no configurations will be changed.
    # @param --url [String] Sets the default URL that is set for newly created inventory items
    def config
      settings = read_config
      settings['url'] = options[:url] || 'http://amazon.com'
      write_config(settings)
    end

    no_commands do
      def path
        Pathname.new("#{ENV['HOME']}/")
      end

      def config_file
        path.join(".stocker.config.yaml")
      end

      def read_config
        config_file_exist?
        YAML.load(config_file.read)
      end

      def write_file(hash)
        file.open('w') { |t| t << hash.to_yaml }
      end

      def write_config(hash)
        config_file.open('w') { |t| t << hash.to_yaml }
      end

      def editor
        read_config[:editor]
      end

      def file
        path.join("~/.stocker.yaml")
      end

      def read_file
        YAML.load(file.read)
      end

      def config_file_exist?
        return true if config_file.exist?
        create_config_file
        return true
      end

      def file_exist?
        return true if file.exist?
        create_file
        return true
      end

      def create_config_file
        FileUtils.touch(config_file)
        settings = {}
        settings['url'] = 'http://amazon.com'
        write_config(settings)
      end

      def create_file
        FileUtils.touch(file)
      end

      def today
        Date.today
      end

      def time(item)
        data = read_file
        match_name(item)
        data[@@item]["checked"] = Time.now
        write_file(data)
      end

      def match_name(item)
        read_file.each_key { |key| @@item = key if key =~ /#{item}/ }
      end
    end
  end
end
