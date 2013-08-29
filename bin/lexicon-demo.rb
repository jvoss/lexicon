require 'lexicon'

# Loads demo data into Lexicon/ObjectStore and starts the poller

# Lexicon connection properties
lexicon_options = {
    :directory  => '/tmp', # currently unused
    :log_opts   => {:level => :DEBUG},
    :redis_opts => {:host  => '127.0.0.1'}
}

# Initialize Lexicon
Lexicon::Base.init(lexicon_options)

# Delete all existing configurations and data
Lexicon::Base.redis.flushall

demo_source_options = {
    :name        => 'Demo Device',
    :description => 'A meaningful description',
    :snmp_opts   => {                # SNMP settings are optional
        :community => 'public',      # if snmp inputs are not used
        :host      => '172.31.0.1',
    }
}

# Create the new source in Lexicon
# Sources are automatically saved upon creation
source_object = Lexicon::Source.new(demo_source_options)

# Create a new InputSNMP objects

# ifHCInOctets - a counter64 SNMP object
# ifIndex is the last digit (6 in this example)
in_bytes_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCInOctets',
    :description => '',
    :interval    => 10,                    # Seconds to poll
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.6.6',
    :type        => :counter64
)

# ifHCOutOctets - a counter 64 SNMP object
out_bytes_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCOutOctets',
    :description => '',
    :interval    => 10,                    # Seconds to poll
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.10.6',
    :type        => :counter64
)

ucast_pkts_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCInUcastPkts',
    :description => '',
    :interval    => 10,
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.7.6',
    :type        => :counter64
)

# Create a new chart
Lexicon::Highcharts.new(
    :axis => {
        in_bytes_obj   => {:type=>'areaspline', :name=>'InBytes',   :color=>'#00ff00'},
        out_bytes_obj  => {:type=>'spline',     :name=>'OutBytes',  :color=>'#0000ff'},
        ucast_pkts_obj => {:type=>'line',       :name=>'UcastPkts', :color=>'#ff9933', :yAxis => 1}
    },
    :data_url => 'data.json',
    :live_url => 'live.json',
    :interval => in_bytes_obj.interval, # it's best to match with what the input brings in
    :name     => 'demo-chart', # the name used to reference the chart via HTTP
    :title    => {:text => 'Demo Device Example'},
    :subtitle => {:text => 'This is a subtitle'},
    :yaxis    => [
        # Primary axis
        {:title => {:text => 'Average Bytes per Second'}},
        {:title => {:text => 'Unicast Packets'}, :opposite => true}
    ]

)

# Create the poller with the associated sources
poller = Lexicon::Poller.new(:sources => [source_object])
poller.run
