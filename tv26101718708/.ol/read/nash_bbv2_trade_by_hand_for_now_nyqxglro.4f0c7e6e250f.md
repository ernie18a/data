Calculation: Globex open = open of the lower-timeframe bar beginning at 5:00 PM Chicago time
Calculation: Midnight open = open of the lower-timeframe bar beginning at 11:00 PM Chicago time
Calculation: NY open = open of the lower-timeframe bar beginning at 8:30 AM Chicago time
Calculation: Higher-timeframe EMA = EMA of close on a timeframe higher than the chart timeframe, using the current bar that may still be forming
Calculation: Bullish fair value gap = on a timeframe higher than the chart timeframe, the current bar’s low is above the high two bars earlier; zone is from that earlier high to the current low. Uses the current bar, which may still be forming.
Calculation: Bearish fair value gap = on a timeframe higher than the chart timeframe, the current bar’s high is below the low two bars earlier; zone is from the current high to that earlier low. Uses the current bar, which may still be forming.
Calculation: Structure high/low = most recent confirmed pivot high/low, using equal lookback lengths on each side
Long: Globex open < Midnight open AND Midnight open < NY open
Long: (close[1] < any available session open level AND close > that level) OR (close[1] <= any available session open level AND high > that level) AND close > Higher-timeframe EMA
Long: close > most recent confirmed Structure high not previously broken since its confirmation AND a prior-chart-bar bullish fair value gap exists whose upper edge is at or below that structure high and within the configured maximum distance below it
Short: Globex open > Midnight open AND Midnight open > NY open
Short: (close[1] > any available session open level AND close < that level) OR (close[1] >= any available session open level AND low < that level) AND close < Higher-timeframe EMA
Short: close < most recent confirmed Structure low not previously broken since its confirmation AND a prior-chart-bar bearish fair value gap exists whose lower edge is at or above that structure low and within the configured maximum distance above it