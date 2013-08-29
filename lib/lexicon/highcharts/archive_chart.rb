module Lexicon

  class Highcharts

    module ArchiveChart

      # Produce an Archival (all available data), non-live updating, chart
      #
      def archive_chart_js
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
              // Only format points with 'bits' or 'Bits' in series name otherwise push value back
              if (point.series.name.indexOf('bits' != -1) || point.series.name.indexOf('Bits' != -1)){
                // Format the number to add commas
                var value = point.y.toString().replace(#{'/\B(?=(\d{3})+(?!\d))/g'}, ",");
                result.push('<span style="font-weight:bold; color:'+ point.series.color +'">' + point.series.name + '</span>' + ': ' + value + '<br />');
              } else {
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
                result.push('<span style="font-weight:bold; color:'+ point.series.color +'">' + point.series.name + '</font></b>' + ': ' + bits + units[i] + '<br/>');
              }
          });

          result.unshift(new Date(this.x).toString() + '<br/>');
          return(result.join(''));
        }; // function tooltipBitsWithUnit

        Highcharts.setOptions({
          global: {
            useUTC: false
          }
        }); // Highcharts.setOptions

        #{request_async_data_to_js}

        $(document).ready(function() {
           chart = #{build_archive_chart}
        }); // $(document).ready
        EJOS
      end # def archive_chart_js

      def build_archive_chart
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

        chart[:chart][:events].delete(:load) # If present (removes live updating)
        chart[:navigator][:adaptToUpdatedData] = false # FIXME do not allow this for archives
        chart[:rangeSelector][:selected] = 1 # Change selection to 1d

        # Build series data - default to last day of data
        chart[:series] = build_series((Time.now.to_i - 86400), Time.now.to_i)

        # Create JSON data
        json = JSON.pretty_generate(chart)
        # Remove quotes from 'navigatorData' function call from JSON if specified in config
        json.gsub!(/"navigatorData"/, 'navigatorData')
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

      # Build a new series array for the timestamps given
      #
      def data_json(start_time, end_time)
        dataset = {}
        @axis.each_pair do |input_obj, options|
          # retrieve data from input_obj
          # TODO any math required on value
          dataset[options[:name]] = []
          input_obj.retrieve(start_time.to_i, end_time.to_i).each_pair do |time, value|
            dataset[options[:name]].push [time * 1000, value]  # convert to JS timestamp
          end
        end

        JSON.pretty_generate(dataset)
      end

      # Asynchronous javascript method
      # Builds the JavaScript function requestAsyncData() and returns it as a string
      #
      def request_async_data_to_js
        script=<<-EJOS
          // AJAX Async Loading Function
          function requestAsyncData(time){
            chart.showLoading('Loading data from server...');

            $.getJSON('#{@data_url}/start='+Math.round(time.min)+'&end='+Math.round(time.max),
              function (json) {

              // Evaluate the new data into a variable (Hash of Arrays)
              new_data = eval(json);

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
      end # def async_data_to_js

    end # module ArchiveChart

  end # class Highcharts

end # module Lexicon
