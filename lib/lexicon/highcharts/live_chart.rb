module Lexicon

  class Highcharts

    module LiveChart

      def build_live_chart
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

        chart[:navigator][:series].delete(:data) # remove navigatorData FIXME

        # Create JSON data
        json = JSON.pretty_generate(chart)
        # Remove quotes from 'navigatorData' function call from JSON if specified in config
        json.gsub!(/"navigatorData"/, 'navigatorData')
        # Remove quotes from 'requestData' function call from JSON if specified in config
        json.gsub!(/"requestData"/, 'requestData')
        # Remove quotes 'tooltipBitsWithUnit' function call from JSON if specified in config
        json.gsub!(/"tooltipBitsWithUnit"/, 'tooltipBitsWithUnit')

        <<-EJOS
            new Highcharts.StockChart(
              #{json}
            );
        EJOS
      end # build_live_chart

      def live_chart_js
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

        #{request_live_data_js}

        $(document).ready(function() {
           chart = #{build_live_chart}
        }); // $(document).ready
        EJOS
      end # live_chart_js

      # Builds the JavaScript function requestData() and returns it as a string
      #
      def request_live_data_js
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
      end # request_live_data_js

    end # module LiveChart

  end # class Highcharts

end # module Lexicon
