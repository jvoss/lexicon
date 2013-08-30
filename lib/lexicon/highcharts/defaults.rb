module Lexicon

  class Highcharts

    CHART = {
        :animation    => false,
        :renderTo     => 'container',
        :zoomType     => 'x',
        :spacingRight => 20,
        :events       => {:load => 'requestData'}
    }

    COLORS = %w( #000000 #2f7ed8 #0d233a #8bbc21 #910000 #1aadce #492970
                 #f28f43 #77a1e5 #c42525 #a6c96a )

    LEGEND = {:enabled => true}

    NAVIGATOR = {
        :adaptToUpdatedData => true,
        :series => { :data => 'navigatorData' }
    }

    PLOT_OPTIONS = {
        :area => {
            :lineWidth => 1,
            :marker    => {:enabled => false},
            :states    => {:hover => {:lineWidth => 1}},
            :threshold => 0
        },
        :line => {
            :lineWidth => 1,
            :marker    => { :enabled => false},
            :states    => {:hover => {:lineWidth => 1}},
            :threshold => 0
        }
    }

    RANGE_SELECTOR = {
        :buttons => [
            {:type => 'minute', :count => 5, :text => '5m'},
            {:type => 'day',    :count => 1, :text => '1d'},
            {:type => 'month',  :count => 1, :text => '1m'},
            {:type => 'year',   :count => 1, :text => '1y'},
            {:type => 'all', :text => 'all'}
        ],
        :selected => 0
    }

    SCROLLBAR = { :liveRedraw => false }

    TOOLTIP = {
        :formatter  => 'tooltipBitsWithUnit',
        :shared     => true,
        :crosshairs => {:color => '#000000', :dashStyle => :solid}
    }

    XAXIS  = {
        :type   => :datetime,
        :title  => {:text => ''},
        :events => {:afterSetExtremes => 'requestAsyncData'}
    }

    YAXIS  = {
        :title => {:text => ''},
        :min   => 0
    }

  end # class Highcharts

end # module Lexicon
