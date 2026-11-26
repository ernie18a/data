Calculation: Trend state on T1 bars = the state of the nearest preceding bar whose Heikin-Ashi body contains both the current bar's Heikin-Ashi open and close, if such a bar is within the preceding lookback window; otherwise up if close >= open and Heikin-Ashi close != Heikin-Ashi open, down if close < open and Heikin-Ashi close != Heikin-Ashi open, or neutral if Heikin-Ashi close = Heikin-Ashi open
Long: previous completed T1 bar Trend state != up AND latest completed T1 bar Trend state = up
Short: previous completed T1 bar Trend state != down AND latest completed T1 bar Trend state = down
Exit: long, latest completed T1 bar Trend state = down
Exit: short, latest completed T1 bar Trend state = up
Long: long position open AND distance in points from latest long fill price to Ask > add-distance parameter
Short: short position open AND distance in points from Bid to latest short fill price > add-distance parameter