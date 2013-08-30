require 'sinatra'
require 'lexicon'

# Arguments
# lexicon-httpd.rb <REDIS IP>
#
raise ArgumentError, 'Redis IP address required' if ARGV[0].nil?

Lexicon::Base.init(
    :directory  => '/tmp',
    :log_opts   => {:level => :DEBUG},
    :redis_opts => {:host => ARGV[0]}
)

get '/:chart_name/live' do
  chart = Lexicon::Highcharts.find_by_name(params[:chart_name])

  <<-HTML
   <html>
    <head>
      <title>Lexicon: #{chart.name}</title>
      <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
      <!-- <script src="http://code.highcharts.com/highcharts.js"></script> -->
      <script src="http://code.highcharts.com/stock/highstock.js"></script>
      <script src="http://code.highcharts.com/modules/exporting.js"></script>
    </head>

    <script>
     #{chart.live_chart_js}
    </script>

    <body>
     <div id="container" style="min-width: 400px; height: 400px; margin: 0 auto"></div>
    </body>
   </html>
  HTML
end

get '/:chart_name/archive' do
  chart = Lexicon::Highcharts.find_by_name(params[:chart_name])

  <<-HTML
   <html>
    <head>
      <title>Lexicon: #{chart.name}</title>
      <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
      <!-- <script src="http://code.highcharts.com/highcharts.js"></script> -->
      <script src="http://code.highcharts.com/stock/highstock.js"></script>
      <script src="http://code.highcharts.com/modules/exporting.js"></script>
    </head>

    <script>
     #{chart.archive_chart_js}
    </script>

    <body>
     <div id="container" style="min-width: 400px; height: 400px; margin: 0 auto"></div>
    </body>
   </html>
  HTML
end

get '/:chart_name/data.json/start=:start_time&end=:end_time' do
  chart = Lexicon::Highcharts.find_by_name(params[:chart_name])

  start_time = params[:start_time].to_i / 1000 # convert to unix timestamp
  end_time   = params[:end_time].to_i / 1000

  start_time = (Time.now - 1.year).to_i if start_time == 0
  end_time   = Time.now.to_i if end_time.nil?

  chart.data_json(start_time, end_time)
end

get '/:chart_name/live.json' do
  chart = Lexicon::Highcharts.find_by_name(params[:chart_name])
  chart.live_json
end



