Calculation: Display RSI = RSI of close, or EMA of that RSI when HA smoothing is selected.
Calculation: HA RSI close = EMA of RSI of close; HA RSI open = (previous HA RSI open + previous HA RSI close) / 2, substituting zero for unavailable previous values.
Calculation: Higher-timeframe bullish bias = last completed higher-timeframe close > its EMA, or last completed higher-timeframe RSI >= its bullish threshold, or both, according to the selected bias mode. Bearish bias = close < its EMA, or RSI <= its bearish threshold, or both, according to the same mode. Higher-timeframe RSI uses the chart RSI length.
Calculation: Divergence pivots = consecutive confirmed price highs or lows, using equal left and right pivot lookbacks; sample display RSI at each price pivot. Evaluate on the bar that confirms the later pivot.
Calculation: Divergence volume confirmation = at the later pivot, volume > its SMA multiplied by a threshold; or that spike AND the lower wick for bullish divergence or upper wick for bearish divergence divided by the bar range >= a wick threshold; or pivot volume < preceding volume AND preceding volume < volume two bars before the pivot, according to the selected mode. The combined modes accept the specified alternatives. Use a minimum tick as the minimum range.
Calculation: Bullish failure-swing state = start or restart at each confirmed display-RSI pivot low <= oversold; then record the first confirmed pivot high > oversold as the break level; then accept a confirmed pivot low > the starting low AND > oversold. A new qualifying starting low restarts the sequence. Reset after a bullish failure-swing signal. If the oversold-origin requirement is disabled, every confirmed pivot low restarts the sequence before it can become the higher low.
Calculation: Bearish failure-swing state = start or restart at each confirmed display-RSI pivot high >= overbought; then record the first confirmed pivot low < overbought as the break level; then accept a confirmed pivot high < the starting high AND < overbought. A new qualifying starting high restarts the sequence. Reset after a bearish failure-swing signal. If the overbought-origin requirement is disabled, every confirmed pivot high restarts the sequence before it can become the lower high. Failure-swing pivots use equal left and right lookbacks, independently of divergence pivots.
Calculation: Squeeze = absolute difference between display RSI and the midline <= compression-distance threshold AND standard deviation of display RSI over the squeeze lookback <= standard-deviation threshold.
Long: Display RSI > midline.
Short: Display RSI <= midline.
Long: Display RSI <= oversold.
Short: Display RSI >= overbought.
Long: High > previous high AND low > previous low.
Short: High < previous high AND low < previous low.
Long: Higher-timeframe bullish bias.
Short: Higher-timeframe bearish bias AND higher-timeframe bullish bias is false.
Long: Display RSI crosses above midline AND optional higher-timeframe bullish bias.
Short: Display RSI crosses below midline AND optional higher-timeframe bearish bias.
Long: HA RSI close > HA RSI open AND previous HA RSI close <= previous HA RSI open AND optional higher-timeframe bullish bias.
Short: HA RSI close < HA RSI open AND previous HA RSI close >= previous HA RSI open AND optional higher-timeframe bearish bias.
Long: A new price-low pivot is confirmed AND ((later pivot low < earlier pivot low AND later pivot RSI > earlier pivot RSI) OR (later pivot low > earlier pivot low AND later pivot RSI < earlier pivot RSI)) AND optional bullish divergence volume confirmation AND optional higher-timeframe bullish bias.
Short: A new price-high pivot is confirmed AND ((later pivot high > earlier pivot high AND later pivot RSI < earlier pivot RSI) OR (later pivot high < earlier pivot high AND later pivot RSI > earlier pivot RSI)) AND optional bearish divergence volume confirmation AND optional higher-timeframe bearish bias.
Long: Bullish failure-swing state has accepted its higher low AND display RSI crosses above its recorded break level AND optional higher-timeframe bullish bias.
Short: Bearish failure-swing state has accepted its lower high AND display RSI crosses below its recorded break level AND optional higher-timeframe bearish bias.
Long: Squeeze is false AND bars since the most recent squeeze > 0 AND bars since that squeeze <= release window AND display RSI crosses above midline plus release distance AND optional higher-timeframe bullish bias.
Short: Squeeze is false AND bars since the most recent squeeze > 0 AND bars since that squeeze <= release window AND display RSI crosses below midline minus release distance AND optional higher-timeframe bearish bias.