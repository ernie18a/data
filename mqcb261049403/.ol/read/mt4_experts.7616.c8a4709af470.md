Calculation: Simple moving average of close = simple moving average of close on the code’s signal timeframe, using its still-forming bar; this timeframe may be higher, equal to, or lower than the chart timeframe
Calculation: Momentum = current close divided by close N bars earlier, multiplied by 100, on the code’s signal timeframe using its still-forming bar; this timeframe may be higher, equal to, or lower than the chart timeframe
Long: current close > simple moving average of close AND Momentum > 100 AND current close > previous completed bar’s close
Short: current close < simple moving average of close AND Momentum < 100 AND current close < previous completed bar’s close
Exit: Long position, Momentum < 100 OR high >= entry price + take-profit distance
Exit: Short position, Momentum > 100 OR low <= entry price - take-profit distance