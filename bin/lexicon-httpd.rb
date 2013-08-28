require 'sinatra'
require 'lexicon'

Lexicon::Base.init(
    :directory  => '/tmp',
    :log_opts   => {:level => :DEBUG},
    :redis_opts => {:host => '172.31.10.16'}
)

#get '/:source_name/:input_name' do
#  source = Lexicon::Source.find_by_name(params[:source_name])
#  input  = nil
#
#  source.inputs.each{|x| input = x if x.name == params[:input_name]}
#
#  chart  = Lexicon::Highcharts.new(
#      :axis => {
#          input => {
#              :type  => 'area',
#              :name  => 'InBytes',
#              :color => '#00ff00'
#          }
#      },
#      :data_url => "/#{source.name}/#{input.name}/data.json",
#      :interval => input.interval,
#      :live_url => "/#{source.name}/#{input.name}/live.json",
#      :title    => {:text => source.name},
#      :subtitle => {:text => 'Drag the plot to zoom'},
#      :yaxis    => {:title => {:text => 'Average Bytes per Second'}}
#  )
#
#  <<-HTML
#   <html>
#    <head>
#      <title>Lexicon: #{params[:source_name]} - #{params[:input_name]}</title>
#      <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
#      <!-- <script src="http://code.highcharts.com/highcharts.js"></script> -->
#      <script src="http://code.highcharts.com/stock/highstock.js"></script>
#      <script src="http://code.highcharts.com/modules/exporting.js"></script>
#    </head>
#
#    <script>
#     #{chart.to_js}
#    </script>
#
#    <body>
#     <div id="container" style="min-width: 400px; height: 400px; margin: 0 auto"></div>
#     <b>Source:</b> #{source.name}<br/>
#     <b>Input:</b> #{input.name}<br/>
#    </body>
#   </html>
#  HTML
#end
#
#get '/:source_name/:input_name/data.json/start=:start_time&end=:end_time' do
#  source = Lexicon::Source.find_by_name(params[:source_name])
#  input  = nil
#
#  start_time = params[:start_time].to_i / 1000 # convert to unix timestamp
#  end_time   = params[:end_time].to_i / 1000
#
#  start_time = (Time.now - 1.year).to_i if start_time == 0
#  end_time   = Time.now.to_i if end_time.nil?
#
#  source.inputs.each{|x| input = x if x.name == params[:input_name]; nil}
#
#  chart  = Lexicon::Highcharts.new(
#      :axis => {
#          input => {
#              :type  => 'area',
#              :name  => 'InBytes',
#              :color => '#00ff00'
#          }
#      },
#      :data_url => "/#{source.name}/#{input.name}/data.json",
#      :interval => input.interval,
#      :live_url => "/#{source.name}/#{input.name}/live.json",
#      :title    => {:text => source.name},
#      :subtitle => {:text => 'Drag the plot to zoom'},
#      :yaxis    => {:title => {:text => 'Average Bytes per Second'}}
#  )
#
#  chart.data_json(start_time, end_time)
#
#end
#
#get '/:source_name/:input_name/live.json' do
#  source = Lexicon::Source.find_by_name(params[:source_name])
#  input  = nil
#
#  source.inputs.each{|x| input = x if x.name == params[:input_name]; nil}
#
#  chart  = Lexicon::Highcharts.new(
#      :axis => {
#          input => {
#              :type  => 'area',
#              :name  => 'InBytes',
#              :color => '#00ff00'
#          }
#      },
#      :data_url => "/#{source.name}/#{input.name}/data.json",
#      :interval => input.interval,
#      :live_url => "/#{source.name}/#{input.name}/live.json",
#      :title    => {:text => source.name},
#      :subtitle => {:text => 'Drag the plot to zoom'},
#      :yaxis    => {:title => {:text => 'Average Bytes per Second'}}
#  )
#
#  chart.live_json
#end



##########################


get '/:chart_name' do
  chart = Lexicon::Highcharts.find_by_name(params[:chart_name])
  input  = nil

  <<-HTML
   <html>
    <head>
      <title>Lexicon: #{chart.title}</title>
      <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
      <!-- <script src="http://code.highcharts.com/highcharts.js"></script> -->
      <script src="http://code.highcharts.com/stock/highstock.js"></script>
      <script src="http://code.highcharts.com/modules/exporting.js"></script>
    </head>

    <script>
     #{chart.to_js}
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



