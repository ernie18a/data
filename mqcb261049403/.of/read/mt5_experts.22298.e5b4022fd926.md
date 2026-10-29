Calculation: ATR range = the highest and lowest ATR values over the indicator lookback on the configured indicator timeframe, which is higher or lower than the chart timeframe; use the last completed indicator bar
Calculation: Step = sensitivity factor × the sum of the highest and lowest ATR values, scaled to whole price points
Calculation: Skyscraper bands = in High/Low mode, candidate upper band = low + 2 × Step and candidate lower band = high − 2 × Step; in Close mode, candidates are close + 2 × Step and close − 2 × Step. In a downtrend, the upper band is the lower of its candidate and prior upper band; in an uptrend, the lower band is the higher of its candidate and prior lower band. Trend turns up when close exceeds the prior upper band and turns down when close falls below the prior lower band.
Long: Previous indicator bar was in a downtrend AND selected indicator bar turns up
Short: Previous indicator bar was in an uptrend AND selected indicator bar turns down
Exit: long, selected indicator bar is in a downtrend
Exit: short, selected indicator bar is in an uptrend