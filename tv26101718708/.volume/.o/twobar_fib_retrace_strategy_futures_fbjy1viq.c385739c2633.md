Calculation: Bar body fraction = absolute(close − open) / (high − low)
Calculation: Bull retrace zone = interval in Bar 2’s range at configured retracement fractions measured down from its high
Calculation: Bear retrace zone = interval in Bar 2’s range at configured retracement fractions measured up from its low
Calculation: Long stop = Bar 2 low − configured stop offset
Calculation: Short stop = Bar 2 high + configured stop offset
Long: Both previous closed bars have body fractions at or above the configured minimum AND volume of the most recently closed bar exceeds volume of the bar before it AND ((both bars close above their opens) OR (they are not both bullish AND Bar 2 close > Bar 1 high)) AND current close > current VWAP AND current low is within the bull retrace zone
Short: Both previous closed bars have body fractions at or above the configured minimum AND volume of the most recently closed bar exceeds volume of the bar before it AND ((both bars close below their opens) OR (they are not both bearish AND Bar 2 close < Bar 1 low)) AND current close < current VWAP AND current high is within the bear retrace zone
Exit: Long, current low <= long stop
Exit: Short, current high >= short stop