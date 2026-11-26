Calculation: Displayed RSI = RSI(close, RSI lookback), or EMA(RSI(close, RSI lookback), smoothing lookback) when HA smoothing is selected
Calculation: HA RSI open = (previous HA RSI open + previous HA RSI close) / 2, initialized from RSI(close, RSI lookback); HA RSI close = EMA(RSI(close, RSI lookback), smoothing lookback)
Calculation: Bullish HTF bias = on chart bars using the last completed T1 bar, close > EMA(close, HTF EMA lookback) in EMA mode, RSI(close, RSI lookback) >= bullish RSI threshold in RSI mode, or both in combined mode
Calculation: Bearish HTF bias = on chart bars using the last completed T1 bar, close < EMA(close, HTF EMA lookback) in EMA mode, RSI(close, RSI lookback) <= bearish RSI threshold in RSI mode, or both in combined mode
Calculation: Bullish HTF filter passes = HTF filter disabled or bullish HTF bias; bearish HTF filter passes = HTF filter disabled or bearish HTF bias
Calculation: Bullish divergence volume filter passes = volume filter disabled or the selected mode accepts a spike, bullish absorption, or volume fade; spike = volume at the price pivot > SMA(volume, volume profile lookback) at the pivot × spike factor; bullish absorption = spike and (min(open, close) - low) / max(high - low, mintick) >= wick ratio; volume fade = volume at the pivot < volume one bar later < volume two bars later
Calculation: Bearish divergence volume filter passes = volume filter disabled or the selected mode accepts a spike, bearish absorption, or volume fade; spike = volume at the price pivot > SMA(volume, volume profile lookback) at the pivot × spike factor; bearish absorption = spike and (high - max(open, close)) / max(high - low, mintick) >= wick ratio; volume fade = volume at the pivot < volume one bar later < volume two bars later
Calculation: Bullish RSI failure swing = an RSI pivot low at or below oversold when an OB/OS origin is required (otherwise any RSI pivot low), followed by an RSI pivot high above oversold setting the break level, then an RSI pivot low above both the origin low and oversold, then RSI crosses above the break level; pivots use equal left and right failure swing lookbacks
Calculation: Bearish RSI failure swing = an RSI pivot high at or above overbought when an OB/OS origin is required (otherwise any RSI pivot high), followed by an RSI pivot low below overbought setting the break level, then an RSI pivot high below both the origin high and overbought, then RSI crosses below the break level; pivots use equal left and right failure swing lookbacks
Long: Displayed RSI > midline
Short: Displayed RSI < midline
Long: Displayed RSI <= oversold
Short: Displayed RSI >= overbought
Long: Displayed RSI crosses above midline AND bullish HTF filter passes
Short: Displayed RSI crosses below midline AND bearish HTF filter passes
Long: Displayed RSI crosses below oversold
Short: Displayed RSI crosses above overbought
Long: Displayed RSI crosses above oversold
Short: Displayed RSI crosses below overbought
Long: Latest confirmed price pivot low < preceding confirmed price pivot low AND displayed RSI at latest pivot > displayed RSI at preceding pivot AND bullish divergence volume filter passes AND bullish HTF filter passes; price pivots use equal left and right divergence lookbacks
Short: Latest confirmed price pivot high > preceding confirmed price pivot high AND displayed RSI at latest pivot < displayed RSI at preceding pivot AND bearish divergence volume filter passes AND bearish HTF filter passes; price pivots use equal left and right divergence lookbacks
Long: Latest confirmed price pivot low > preceding confirmed price pivot low AND displayed RSI at latest pivot < displayed RSI at preceding pivot AND bullish divergence volume filter passes AND bullish HTF filter passes; price pivots use equal left and right divergence lookbacks
Short: Latest confirmed price pivot high < preceding confirmed price pivot high AND displayed RSI at latest pivot > displayed RSI at preceding pivot AND bearish divergence volume filter passes AND bearish HTF filter passes; price pivots use equal left and right divergence lookbacks
Long: HA RSI close > HA RSI open AND bullish HTF filter passes
Short: HA RSI close < HA RSI open AND bearish HTF filter passes
Long: HA RSI changes from bearish to bullish AND bullish HTF filter passes
Short: HA RSI changes from bullish to bearish AND bearish HTF filter passes
Long: HA RSI is bullish AND displayed RSI < midline
Short: HA RSI is bearish AND displayed RSI > midline
Long: Current high > previous high AND current low > previous low
Short: Current high < previous high AND current low < previous low
Long: Bullish HTF bias
Short: Bearish HTF bias
Long: Bullish RSI failure swing AND bullish HTF filter passes
Short: Bearish RSI failure swing AND bearish HTF filter passes
Long: abs(Displayed RSI - midline) <= compression distance AND StDev(Displayed RSI, squeeze lookback) <= maximum RSI standard deviation, and within the release window after a prior squeeze, Displayed RSI is not compressed and crosses above midline + release distance AND bullish HTF filter passes
Short: abs(Displayed RSI - midline) <= compression distance AND StDev(Displayed RSI, squeeze lookback) <= maximum RSI standard deviation, and within the release window after a prior squeeze, Displayed RSI is not compressed and crosses below midline - release distance AND bearish HTF filter passes