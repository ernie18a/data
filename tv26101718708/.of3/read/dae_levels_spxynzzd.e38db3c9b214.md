Calculation: opening_range_high = highest high of chart bars in the current session's first opening range length minutes, once that period has ended
Calculation: opening_range_low = lowest low of chart bars in the current session's first opening range length minutes, once that period has ended
Calculation: opening_range_breakout = bullish if the latest close after the opening range period of the current session that lies outside [opening_range_low, opening_range_high] is above opening_range_high; bearish if it is below opening_range_low; none if there is no such close
Calculation: tolerance = tick size * tick count
Calculation: last_sweep(T) = type and close of the most recent bar i, 1 <= i <= sweep lookback, counted back from the current T bar, that is a bullish sweep (low[i] < low[i+1] AND close[i] > low[i+1]) or, failing that, a bearish sweep (high[i] > high[i+1] AND close[i] < high[i+1]); the current T bar is the bar still forming for T2 and the last completed bar for T1, T3 and T4; current close is the close of the current T bar
Calculation: sweep_bias(T) = bullish if last_sweep(T) is a bullish sweep and current close >= its close, or a bearish sweep and current close > its close; bearish if last_sweep(T) is a bearish sweep and current close <= its close, or a bullish sweep and current close < its close; none if last_sweep(T) does not exist
Calculation: bullish_count = number of T in T1..T4 with sweep_bias(T) = bullish, where T1 is shorter than T2, T2 is shorter than T3, and T3 is shorter than T4
Calculation: bearish_count = number of T in T1..T4 with sweep_bias(T) = bearish
Calculation: swing_high_level = most recent pivot high(high, pivot length, pivot length), or none once a close above it has occurred since its confirmation
Calculation: swing_low_level = most recent pivot low(low, pivot length, pivot length), or none once a close below it has occurred since its confirmation
Long: bullish_count >= minimum aligned timeframe count
Long: opening_range_breakout = bullish AND bar time within entry window length after regular session open AND low <= opening_range_high + tolerance AND close > opening_range_high AND low < low[1] AND close > low[1] AND bullish_count >= minimum aligned timeframe count AND round(market breadth percentage of the still-forming T2 bar) <= breadth upper limit AND volume > SMA(volume, volume length)
Long: low < swing_low_level AND close > swing_low_level
Long: close > swing_high_level
Short: bearish_count >= minimum aligned timeframe count
Short: opening_range_breakout = bearish AND bar time within entry window length after regular session open AND high >= opening_range_low - tolerance AND close < opening_range_low AND high > high[1] AND close < high[1] AND bearish_count >= minimum aligned timeframe count AND round(market breadth percentage of the still-forming T2 bar) >= breadth lower limit AND volume > SMA(volume, volume length)
Short: high > swing_high_level AND close < swing_high_level
Short: close < swing_low_level