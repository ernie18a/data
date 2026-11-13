Calculation: Bias(timeframe) = +1 if EMA(close, short) > EMA(close, medium) AND close > EMA(close, long); -1 if EMA(close, short) < EMA(close, medium) AND close < EMA(close, long); otherwise 0. All EMAs and close are taken on that timeframe's bars; lookbacks satisfy short < medium < long. For a timeframe higher than the chart, use the bar still forming.
Calculation: HTF set = four timeframes, each higher than the chart timeframe, with Bias computed on each one's still-forming bar.
Long: Bias(chart timeframe) == +1
Long: for any timeframe in HTF set, Bias == +1 on the current chart bar AND Bias != +1 on the previous chart bar
Long: number of timeframes in HTF set with Bias == +1 > number with Bias == -1
Short: Bias(chart timeframe) == -1
Short: for any timeframe in HTF set, Bias == -1 on the current chart bar AND Bias != -1 on the previous chart bar
Short: number of timeframes in HTF set with Bias == -1 > number with Bias == +1