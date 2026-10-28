Calculation: Efficiency ratio = absolute change in close over the baseline lookback divided by the sum of absolute bar-to-bar close changes over that lookback; 0 if the sum is 0
Calculation: Adaptive baseline = recursively smoothed average of the close-based SMA and VWMA, with smoothing speed adjusted by the efficiency ratio using a faster and a slower smoothing factor
Calculation: Volatility bands = adaptive baseline plus and minus an ATR-based buffer; ATR uses the baseline lookback and the buffer is exponentially smoothed
Calculation: VFI = EMA of summed signed, volume-capped flow divided by volume SMA; flow is positive or negative according to the change in HLC3 from the prior chart bar, volume is capped at a multiple of its SMA, and the lookback is longer than the baseline lookback
Calculation: Macro trend = close above EMA on the last completed higher-timeframe bar
Long: close > upper volatility band AND VFI > 0 AND macro trend is up AND current-chart-timeframe VIX close < its EMA
Short: close < lower volatility band AND VFI < 0 AND macro trend is down AND current-chart-timeframe VIX close > its EMA
Exit: long, efficiency ratio is below its chop threshold OR (prior regime is bullish AND VFI < 0)
Exit: short, efficiency ratio is below its chop threshold OR (prior regime is bearish AND VFI > 0)