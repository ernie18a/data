Calculation: Williams VIX Fix (WVF) = 100 × (highest close over its lookback − low) / highest close over its lookback.
Calculation: WVF upper band = SMA of WVF plus a multiplier times the standard deviation of WVF, using the same band lookback.
Calculation: WVF range threshold = highest WVF over a separate lookback times a multiplier.
Calculation: WVF reversal = (previous WVF >= previous WVF upper band OR previous WVF >= previous WVF range threshold) AND WVF < WVF upper band AND WVF < WVF range threshold AND low > previous low AND close > previous high AND (close < close at a longer lookback OR close < close at a shorter lookback) AND close > close at a strength lookback.
Calculation: Efficiency ratio = absolute change in close over its lookback divided by the sum of absolute bar-to-bar close changes over that lookback; use zero when the denominator is zero.
Calculation: Capitulation gate = a WVF reversal occurred on the current bar or within an inclusive arm window AND ADX < threshold AND efficiency ratio < threshold; each of these three requirements can independently be disabled.
Calculation: CVI = (close − lowest low) / (highest high − lowest low) over its lookback; use 0.5 when the range is zero.
Calculation: Signed volume = volume if close >= open, otherwise negative volume.
Calculation: Candle-signed OBV = cumulative sum of signed volume.
Calculation: Momentum bias = 100 × (close − close at a momentum lookback) / EMA of high − low; use zero when the EMA is not positive. Positive bias is the maximum of zero and the HMA of the rolling sum of positive momentum bias; negative bias is the maximum of zero and the HMA of the rolling sum of absolute negative momentum bias. Both use the same sum and HMA lookbacks.
Calculation: Bullish candle percentage = 100 × the number of bars with close >= open divided by the lookback length.
Long: WVF reversal on the chart timeframe.
Long: Capitulation gate on the chart timeframe.
Long: Capitulation gate on any of the designated signal timeframes. For a timeframe higher than the chart timeframe, use its last completed bar on historical bars and its forming bar in real time; for a lower timeframe, use the last available intrabar.
Long: Low <= lower Bollinger Band AND close > lower Bollinger Band.
Short: Close <= lower Bollinger Band.
Short: Previous CVI >= threshold AND current CVI < threshold.
Long: Close > session VWAP of (high + low + close) / 3.
Short: Close <= session VWAP of (high + low + close) / 3.
Long: Candle-signed OBV > candle-signed OBV at its lookback.
Short: Candle-signed OBV <= candle-signed OBV at its lookback.
Long: EMA of signed volume > 0.
Short: EMA of signed volume <= 0.
Long: Shorter-period EMA of close > longer-period EMA of close.
Short: Shorter-period EMA of close <= longer-period EMA of close.
Long: Positive momentum bias > negative momentum bias.
Short: Positive momentum bias <= negative momentum bias.
Long: CVI < midpoint.
Short: CVI >= midpoint.
Long: Short-period EMA of close > Bollinger Band basis AND close > Bollinger Band basis AND shorter-period SMA of (high + low) / 2 >= longer-period SMA of (high + low) / 2.
Short: Short-period EMA of close <= Bollinger Band basis OR close <= Bollinger Band basis OR shorter-period SMA of (high + low) / 2 < longer-period SMA of (high + low) / 2.
Long: Bullish candle percentage > upper threshold.
Short: Bullish candle percentage < lower threshold.
Long: Shorter-period EMA of close > longer-period EMA of close on the higher bias timeframe, using its last completed bar on historical bars and its forming bar in real time.
Short: Shorter-period EMA of close <= longer-period EMA of close on the higher bias timeframe, using its last completed bar on historical bars and its forming bar in real time.
Exit: long, high >= entry price × (1 + take-profit percentage) OR low <= entry price × (1 − stop-loss percentage) OR bars elapsed since entry >= timeout.