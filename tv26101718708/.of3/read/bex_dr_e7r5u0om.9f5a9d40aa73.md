Calculation: RangeHigh(W) = highest high over the bars of the latest completed occurrence of window W, where each bar's high is the high of the T1 bar still forming at that bar if the chart timeframe is shorter than T1, else the bar's own high
Calculation: RangeLow(W) = lowest low over the bars of the latest completed occurrence of window W, where each bar's low is the low of the T1 bar still forming at that bar if the chart timeframe is shorter than T1, else the bar's own low
Long: close crosses above RangeHigh(S1) AND first such crossing within E1
Long: close crosses above RangeHigh(S2) AND first such crossing within E2
Long: close crosses above RangeHigh(S3) AND first such crossing within E3
Short: close crosses below RangeLow(S1) AND first such crossing within E1
Short: close crosses below RangeLow(S2) AND first such crossing within E2
Short: close crosses below RangeLow(S3) AND first such crossing within E3