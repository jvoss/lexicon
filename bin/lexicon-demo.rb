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
        :version   => :SNMPv2c
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

ucast_pkts_in_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCInUcastPkts',
    :description => '',
    :interval    => 10,
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.7.6',
    :type        => :counter64
)

ucast_pkts_out_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCOutUcastPkts',
    :description => '',
    :interval    => 10,
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.11.6',
    :type        => :counter64
)

bcast_pkts_in_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCInBroadcastPkts',
    :description => '',
    :interval    => 10,
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.9.6',
    :type        => :counter64
)

bcast_pkts_out_obj = Lexicon::InputSNMP.new(
    :name        => 'fa4-ifHCOutBroadcastPkts',
    :description => '',
    :interval    => 10,
    :source      => source_object,
    :oid         => '1.3.6.1.2.1.31.1.1.1.13.6',
    :type        => :counter64
)


cpu_obj = Lexicon::InputSNMP.new(
    :name        => 'cpmCPUTotal5secRev',
    :description => '',
    :interval    => 10,
    :source      => source_object,
    :oid         => '1.3.6.1.4.1.9.9.109.1.1.1.1.6.1',
    :type        => :gauge32
)

# Create a new chart
Lexicon::Highcharts.new(
    :axis => {
        in_bytes_obj => {
            :type  => 'area',
            :name  => 'InBits',
            :color => '#00ff00'
        },
        out_bytes_obj => {
            :type  => 'line',
            :name  => 'OutBits',
            :color => '#0000ff'
        },
        ucast_pkts_in_obj => {
            :type  => 'line',
            :name  => 'Unicast In',
            :color => '#ff9933',
            :yAxis => 1
        },
        ucast_pkts_out_obj => {
            :type  => 'line',
            :name  => 'Unicast Out',
            :color => '#ffcc33',
            :yAxis => 1
        },
        bcast_pkts_in_obj => {
            :type  => 'line',
            :name  => 'Broadcast In',
            :color => '#996600',
            :yAxis => 1
        },
        bcast_pkts_out_obj => {
            :type  => 'line',
            :name  => 'Broadcast Out',
            :color => '#990000',
            :yAxis => 1
        },
        cpu_obj => {
            :type  => 'line',
            :name  => '% CPU',
            :color => '#ff0000',
            :yAxis => 2
        }
    },
    :data_url => 'data.json',
    :live_url => 'live.json',
    :interval => in_bytes_obj.interval, # it's best to match with what the input brings in (update interval of the chart)
    :name     => 'demo-chart', # the name used to reference the chart via HTTP
    :title    => {:text => 'Demo Device Example'},
    :subtitle => {:text => 'This is a subtitle'},
    :yaxis    => [
        # yAxis 0
        {:title => {:text => 'Bits per Second'}, :min => 0},
        # yAxis 1
        {:title => {:text => 'Packets per Second'}, :opposite => true, :min => 0},
        # yAxis 2
        {:title => {:text => ''}, :min => 0, :max => 100, :labels => {:enabled => false}}
    ]
)

# Create the poller with the associated sources
poller = Lexicon::Poller.new(:sources => [source_object])
poller.run
