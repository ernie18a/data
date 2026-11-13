Calculation: OR_high, OR_low = highest high and lowest low of the bars from the first bar of the session through the end of a fixed opening window; the range is locked after the window ends
Calculation: SessionVWAP = cumulative sum(hlc3*volume) / cumulative sum(volume), reset at the first bar of each session, including the current bar
Calculation: VolAvg = simple moving average of volume over a lookback, including the current bar
Calculation: ATR = average true range on the chart timeframe, last completed bar at entry
Long: opening range is locked AND no long signal has fired yet in this session AND close crosses above OR_high (previous close <= OR_high AND close > OR_high) AND close > SessionVWAP AND volume >= multiple * VolAvg
Short: opening range is locked AND no short signal has fired yet in this session AND close crosses below OR_low (previous close >= OR_low AND close < OR_low) AND close < SessionVWAP AND volume >= multiple * VolAvg
Exit: long, low <= entry price - stop_multiple * ATR OR high >= entry price + target_multiple * ATR (target_multiple > stop_multiple)
Exit: short, high >= entry price + stop_multiple * ATR OR low <= entry price - target_multiple * ATR (target_multiple > stop_multiple)