# Lexicon

A graphing utility based on Highcharts

Lexicon is designed to take inputs from various sources polled at specified
intervals. Much like the PHP project Cacti, it can be used for a variety of
graphing situations such as system administration.

***Currently this is proof of concept and should be considered Alpha at best***

## Screenshot

![Screenshot](https://raw.github.com/jvoss/lexicon/master/examples/chart.png)

## Installation

Add this line to your application's Gemfile:

    gem 'lexicon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lexicon

## Usage

To get started, look at examples/lexicon-demo.rb

Adjust the demo file to point at the appropriate SNMP OIDs and Redis server
then launch the example to configure Redis and run the poller:

    ruby <path to example>/lexicon-demo.rb

Then launch the web server:

    lexicon-httpd.rb <REDIS SERVER IP> -o 0.0.0.0

Open a web browser, http://localhost:4567/<chart name>/live or /archive:

View live URL:    http://localhost:4567/demo-chart/live
View archive URL: http://localhost:4567/demo-chart/archive

Custom input objects can be created by extending the functionality of the
Lexicon::Input class. See lib/lexicon/inputs/snmp.rb for example. Ensure that
your new Input class responds to the methods specified in Lexicon::Input.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
