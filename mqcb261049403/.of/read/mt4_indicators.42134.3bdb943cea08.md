Calculation: HTF = a timeframe higher than the chart timeframe; every value below is read from the HTF bar that contains the current chart bar (the bar still forming, not the last completed one), using that bar's current values
Calculation: fastMA = linear-weighted moving average of typical price ((high+low+close)/3) over HTF bars, with a lookback much shorter than the Bollinger lookback
Calculation: BBupper, BBlower = standard Bollinger Bands (SMA of close +/- deviation multiple of standard deviation) over HTF bars, with the band values displaced back by a fixed number of bars
Long: fastMA > BBupper
Short: fastMA < BBlower