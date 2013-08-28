require 'json'
require 'lexicon'
require 'lexicon/highcharts/defaults'

module Lexicon

  class Highcharts

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

    # Build a new series array based on the times requested
    #
    def data_json(start_time, end_time)
      dataset = {}
      @axis.each_pair do |input_obj, options|
        # retrieve data from input_obj
        # TODO any math required on value
        dataset[options[:name]] = []
        input_obj.retrieve(start_time.to_i - 300, end_time.to_i).each_pair do |time, value|
          dataset[options[:name]].push [time * 1000, value]  # convert to JS timestamp
        end
      end

      JSON.pretty_generate(dataset)
    end

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

    def to_js
      <<-EJOS
        var chart; // global

        /**
        * http://bateru.com/news/2011/08/code-of-the-day-javascript-convert-bytes-to-kb-mb-gb-etc/
        * @function: getBitsWithUnit()
        * @purpose: Converts bits to the most simplified unit.
        * @param: (number) bits, the amount of bits
        * @returns: (string)
        */
        function tooltipBitsWithUnit() {
          result = []
          $.each(this.points, function (i, point) {
              bits = point.y;
              if (isNaN(bits)) {
                  return;
              }
              var units = [' bits', ' Kb', ' Mb', ' Gb', ' Tb', ' Pb', ' Eb', ' Zb', ' Yb'];
              var amountOf2s = Math.floor(Math.log(+bits) / Math.log(2));
              if (amountOf2s < 1) {
                  amountOf2s = 0;
              }
              var i = Math.floor(amountOf2s / 10);
              bits = +bits / Math.pow(2, 10 * i);

              // Rounds to 2 decimals places.
              if (bits.toString().length > bits.toFixed(3).toString().length) {
                  bits = bits.toFixed(2);
              }
              result.push('<b>' + point.series.name + '</b>' + ': ' + bits + units[i] + '<br/>');
          });

          result.unshift(new Date(this.x).toString() + '<br/>');
          return (result[0] + result[1] + result[2]);
        }; // function tooltipBitsWithUnit

        Highcharts.setOptions({
          global: {
            useUTC: false
          }
        }); // Highcharts.setOptions

        #{build_asyncData}

        #{build_requestData}

        $(document).ready(function() {
           chart = #{build_chart}
        }); // $(document).ready
      EJOS
    end # def to_js

    private

    def build_chart
      chart  = {}

      # Build chart configuration
      chart[:chart]         = @chart
      chart[:colors]        = @colors
      chart[:title]         = @title
      chart[:subtitle]      = @subtitle
      chart[:xAxis]         = @xaxis
      chart[:yAxis]         = @yaxis
      chart[:tooltip]       = @tooltip
      chart[:legend]        = @legend
      chart[:plotOptions]   = @plotOptions
      chart[:rangeSelector] = @rangeSelector
      chart[:navigator]     = @navigator
      chart[:scrollbar]     = @scrollbar

      # Build series data
      chart[:series] = build_series((Time.now.to_i - 300), Time.now.to_i)

      # Create JSON data
      json = JSON.pretty_generate(chart)
      # Remove quotes from 'navigatorData' function call from JSON if specified in config
      json.gsub!(/"navigatorData"/, 'navigatorData')
      # Remove quotes from 'requestData' function call from JSON if specified in config
      json.gsub!(/"requestData"/, 'requestData')
      # Remove quotes from 'requestData' function call from JSON if specified in config
      json.gsub!(/"requestAsyncData"/, 'requestAsyncData')
      # Remove quotes 'tooltipBitsWithUnit' function call from JSON if specified in config
      json.gsub!(/"tooltipBitsWithUnit"/, 'tooltipBitsWithUnit')

      <<-EJOS
          new Highcharts.StockChart(
            #{json}
          );
      EJOS
    end # def build_highstock

    # Builds the JavaScript function requestAsyncData() and returns it as a string
    #
    def build_asyncData
       script=<<-EJOS
        // AJAX Async Loading Function
        function requestAsyncData(time){
          chart.showLoading('Loading data from server...');

          $.getJSON('#{@data_url}/start='+Math.round(time.min)+'&end='+Math.round(time.max),
            function (json) {

            // Evaluate the new data into a variable (Hash of Arrays)
            new_data = eval(json);

            console.log("Loading Async Data!");

            chart.series.forEach(function(series){
              // Ignore 'Navigator' data series if exists
              if (series.name != 'Navigator'){
                series.setData(new_data[series.name]);
              }
            }); // chart.series.forEach

            chart.hideLoading();
          }); // $.getJSON

        } // function requestAsyncData()

        // Navigator Data Loading
        var navigatorData = (function(){
          var date = new Date();
          var max  = date.getTime();
          var min  = max - 31556900000; // Minus one year from now

          var data = null;

          $.ajax({

            'async':  false,
            'global': false,
            'url': '#{@data_url}/start='+Math.round(min)+'&end='+Math.round(max),
            'dataType': 'json',
            'success': function(json){
              new_data = eval(json);

              // Uses values from first key in hash for navigator
              data = new_data[Object.keys(new_data)[0]];
            }

          });
          return data;
        })(); // var navigatorData

      EJOS
      script
    end # build_asyncData

    # Builds the JavaScript function requestData() and returns it as a string
    #
    def build_requestData
      script=<<-EJOS
        // AJAX updating function
        function requestData(){

          $.getJSON('#{@live_url}',
            function (json) {

            // Evaluate the new data into a variable (Hash)
            new_data = eval(json);

            chart.series.forEach(function(series){
              shift = #{@shift};

              // Ignore 'Navigator' data series if exists
              if (series.name != 'Navigator'){
                // Only add the point if it currently does not exist
                if (series.points[series.points.length-1]['x'] < new_data[series.name][0]) {
                  series.addPoint(new_data[series.name], true, shift, false);
                }
              }
            });
          }); // $.getJSON

          // Set the timeout for refreshing data
          setTimeout(requestData, #{@interval.to_i} * 1000);
        } // function requestData()
      EJOS
      script
    end # def build_requestData

    def build_series(time_start, time_end)
      series_array = []

      @axis.each_pair do |input_obj, options|
        dataset = {}
        dataset.merge! options

        # retrieve data from input_obj
        # TODO any math required on value
        dataset[:data] = []
        input_obj.retrieve(time_start.to_i - 300, time_end.to_i).each_pair do |time, value|
          dataset[:data].push [time * 1000, value]  # convert to JS timestamp
        end

        series_array.push dataset
      end

      series_array
    end # def build_series

    # Save Highcharts object to Redis
    # **Will overwrite any existing source with same name**
    #
    def save
      result = Base.redis.hset(:charts, self.title[:text], Marshal.dump(self))
      Log.debug "Saving Chart object to Redis: #{self.title[:text]}"
      result
    end

  end # class Highcharts

end # module Lexicon
