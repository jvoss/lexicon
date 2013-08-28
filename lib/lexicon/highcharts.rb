require 'json'
require 'lexicon'
require 'lexicon/highcharts/archive_chart'
require 'lexicon/highcharts/live_chart'
require 'lexicon/highcharts/defaults'

module Lexicon

  class Highcharts
    include ArchiveChart
    include LiveChart

    INTERFACE_CHART_COLORS = %w( #000000 #2f7ed8 #0d233a #8bbc21 #910000 #1aadce
                                 #492970 #f28f43 #77a1e5 #c42525 #a6c96a )

    attr_reader :name, :title

    #
    # @axis = { input_object => {Highcharts axis options?} }
    #
    def initialize(opts={})
      #@js_library = opts[:js_library]               # URL location of Highstock JS library
      @axis       = opts[:axis]            ||= {}    # Hash containing axis information
      @shift      = opts[:shift]           ||= true  # Highcharts option to shift chart
      @data_url   = opts[:data_url]                  # URL to pull time ranged JSON data
      @live_url   = opts[:live_url]                  # URL to pull live JSON data
      @interval   = opts[:interval]                  # Update interval in seconds
      @name       = opts[:name]

      @chart         = opts[:chart]        ||= CHART
      @colors        = opts[:colors]       ||= INTERFACE_CHART_COLORS
      @title         = opts[:title]        ||= {:text => 'title'}
      @subtitle      = opts[:subtitle]     ||= {:text => 'subtitle'}
      @xaxis         = opts[:xaxis]        ||= XAXIS
      @yaxis         = opts[:yaxis]        ||= YAXIS
      @tooltip       = opts[:tooltip]      ||= TOOLTIP
      @legend        = opts[:legend]       ||= LEGEND
      @plotOptions   = opts[:plotOptions]  ||= PLOT_OPTIONS
      @rangeSelector = opts[:rangeSelector]||= RANGE_SELECTOR
      @navigator     = opts[:navigator]    ||= NAVIGATOR
      @scrollbar     = opts[:scrollbar]    ||= SCROLLBAR

      save # Save chart object to Redis
    end # def initialize

    # Delete self from Redis
    #
    def delete
      result = Base.redis.hdel(:charts, name)
      if result == 1
        delete_all_inputs
        Log.info "Deleting Chart object from Redis: #{name}"
      else
        raise UnknownChart, "Cannot delete non-existent Chart object in Redis: #{name}"
      end
      result
    end

    # Find a chart object by name (string)
    #
    def self.find_by_name(name)
      marshal = Base.redis.hget(:charts, name)
      if marshal
        chart_obj = Marshal.load(marshal)
        return chart_obj
      end
    end

    # Return live data (well... most current when asked)
    def live_json
      json_hash = {}

      @axis.each_pair do |input_obj, options|
        # retrieve data from input_obj
        dataset = input_obj.retrieve_last

        # TODO any math required on value
        json_hash[options[:name]] = []

        dataset.each_pair do |time, value|
          json_hash[options[:name]] = [time * 1000, value] # convert to JS timestamp
        end
      end # @axis.each_pair

      JSON.pretty_generate(json_hash)
    end # def live_json

    private

    def build_series(time_start, time_end)
      series_array = []

      @axis.each_pair do |input_obj, options|
        dataset = {}
        dataset.merge! options

        # retrieve data from input_obj
        # TODO any math required on value

        dataset[:data] = []
        input_obj.retrieve(time_start.to_i, time_end.to_i).each_pair do |time, value|
          dataset[:data].push [time * 1000, value]  # convert to JS timestamp
        end

        series_array.push dataset
      end

      series_array
    end # def build_series

    # Save Highcharts object to Redis
    # **Will overwrite any existing chart with same name**
    #
    def save
      result = Base.redis.hset(:charts, self.title[:text], Marshal.dump(self))
      Log.debug "Saving Chart object to Redis: #{self.title[:text]}"
      result
    end

  end # class Highcharts

end # module Lexicon
