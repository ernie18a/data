Calculation: Volume change = volume - volume[1]
Calculation: Pivot level = Pivot_AllLevels(pivot level output, current chart bar)
Calculation: ASCTrend buy signal = ASCTrend1sig(buy output, current chart bar)
Calculation: ASCTrend sell signal = ASCTrend1sig(sell output, current chart bar)
Calculation: Previous completed ASCTrend buy signal = ASCTrend1sig(buy output, previous completed chart bar)
Calculation: Previous completed ASCTrend sell signal = ASCTrend1sig(sell output, previous completed chart bar)
Long: (Standard deviation(median price, lookback) > threshold parameter AND ASCTrend buy signal > 0 AND ASCTrend buy signal < low AND entry price > Pivot level AND Volume change >= volume-change parameter) OR (ASCTrend buy signal > 0 AND BrainTrend1Sig(buy output, current chart bar) > 0 AND ASCTrend buy signal < low AND BrainTrend1Sig(buy output, current chart bar) < low AND Volume change > volume-change parameter)
Short: (Standard deviation(median price, lookback) > threshold parameter AND ASCTrend sell signal > 0 AND ASCTrend sell signal > high AND entry price < Pivot level AND Volume change >= volume-change parameter) OR (ASCTrend sell signal > 0 AND BrainTrend1Sig(sell output, current chart bar) > 0 AND ASCTrend sell signal > high AND BrainTrend1Sig(sell output, current chart bar) > high AND Volume change > volume-change parameter)
Exit: long, current time's minute-of-hour = scheduled-minute parameter AND Previous completed ASCTrend buy signal = 0 AND ASCTrend buy signal = 0 AND elapsed time since entry <= holding-duration parameter
Exit: short, current time's minute-of-hour = scheduled-minute parameter AND Previous completed ASCTrend sell signal = 0 AND ASCTrend sell signal = 0 AND elapsed time since entry <= holding-duration parameter