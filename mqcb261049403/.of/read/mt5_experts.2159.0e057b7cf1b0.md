Calculation: Digital histogram = the difference between a faster and a slower finite impulse response filter of a selectable OHLC-derived price, using separate coefficient arrays ordered from the current bar backward; divide by a positive price-unit scale. Calculate it on the chart timeframe for indicator markings and on a selectable higher or lower timeframe for trading decisions, using the last completed bar or the still-forming bar according to the selected signal-bar offset.
Calculation: Signal line = a selectable moving average of the digital histogram, calculated on the chart timeframe.
Calculation: Histogram state = 4 if the digital histogram is positive and rising; 3 if positive and falling; 0 if negative and falling; 1 if negative and rising; otherwise 2. Calculate it on the same timeframe and bar as the trading digital histogram.
Long: chart-timeframe digital histogram > 0 AND chart-timeframe digital histogram != its previous-bar value
Short: chart-timeframe digital histogram < 0 AND chart-timeframe digital histogram != its previous-bar value
Long: chart-timeframe digital histogram > previous-bar signal line
Short: chart-timeframe digital histogram < previous-bar signal line
Long: trading digital histogram > 0 AND previous-bar trading digital histogram <= 0
Short: trading digital histogram < 0 AND previous-bar trading digital histogram >= 0
Long: trading digital histogram > its previous-bar value AND its previous-bar value < its value two bars ago
Short: trading digital histogram < its previous-bar value AND its previous-bar value > its value two bars ago
Long: histogram state > its previous-bar value AND its previous-bar value < its value two bars ago
Short: histogram state < its previous-bar value AND its previous-bar value > its value two bars ago
Long: trading digital histogram > histogram state AND previous-bar trading digital histogram <= previous-bar histogram state
Short: trading digital histogram < histogram state AND previous-bar trading digital histogram >= previous-bar histogram state
Exit: long, trading digital histogram < 0 OR trading digital histogram < its previous-bar value OR histogram state < its previous-bar value OR trading digital histogram < histogram state
Exit: short, trading digital histogram > 0 OR trading digital histogram > its previous-bar value OR histogram state > its previous-bar value OR trading digital histogram > histogram state
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance