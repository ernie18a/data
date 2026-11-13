Calculation: WT1 = EMA(((hlc3 - esa) / (0.015 * d)), avg_len), where esa = EMA(hlc3, ch_len) and d = EMA(abs(hlc3 - esa), ch_len)
Calculation: WT2 = SMA(WT1, 4)
Calculation: MFI = SMA(((close - open) / (high - low)) * k, p) - c, with k a positive multiplier and c a constant offset, on chart timeframe bars
Calculation: EMA_long, EMA_short = EMA of close computed on bars of a timeframe equal to or higher than the chart timeframe, using the still-forming bar of that timeframe; EMA_short lookback < EMA_long lookback
Calculation: ATR_entry = ATR value on the entry bar
Calculation: LL_entry = lowest low over a lookback of the bars before the entry bar (excluding the entry bar), taken as of the entry bar
Calculation: HH_entry = highest high over a lookback of the bars before the entry bar (excluding the entry bar), taken as of the entry bar
Long: no open position AND close > EMA_long AND WT2 < 0 AND WT1 crosses WT2 (either direction) on this bar AND WT2 <= oversold level (negative) AND WT1 >= WT2 AND MFI > 0 AND close > EMA_short AND close[1] < EMA_short[1] AND (close > EMA_short on each of bars 2,3,4 ago OR on each of bars 5,6,7 ago OR on each of bars 8,9,10 ago)
Short: no open position AND close < EMA_long AND WT2 > 0 AND WT1 crosses WT2 (either direction) on this bar AND WT2 >= overbought level (positive) AND WT1 <= WT2 AND MFI < 0 AND close < EMA_short AND close[1] > EMA_short[1] AND (close < EMA_short on each of bars 2,3,4 ago OR on each of bars 5,6,7 ago OR on each of bars 8,9,10 ago)
Exit: long, ATR mode: high >= entry_price + ATR_entry * profit_factor OR low <= entry_price - ATR_entry * stop_factor
Exit: short, ATR mode: low <= entry_price - ATR_entry * profit_factor OR high >= entry_price + ATR_entry * stop_factor
Exit: long, lowest-low mode (alternative to ATR mode): low <= LL_entry OR high >= entry_price + (entry_price - LL_entry) * profit_factor
Exit: short, highest-high mode (alternative to ATR mode): high >= HH_entry OR low <= entry_price - (HH_entry - entry_price) * profit_factor