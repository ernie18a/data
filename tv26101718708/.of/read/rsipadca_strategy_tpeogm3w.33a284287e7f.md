Calculation: RSI = relative strength index of close
Calculation: SMA = simple moving average of close, long lookback
Calculation: layer_1 = close of the bar where the initial Long fired; layer_k (k=2..6) = layer_1 * (1 - p_k/100), with p_2 < p_3 < p_4 < p_5 < p_6 (deeper layer for larger k)
Calculation: avg_price = average entry price of all open long entries
Calculation: exit_all_level = avg_price * (1 + P_all/100)
Long: position is flat AND RSI crosses above a fixed oversold level (previous RSI <= level, current RSI > level) AND close < SMA
Long: (add entry k, k=2..6) position is long with exactly k-1 open entries AND low <= layer_k (limit buy at layer_k)
Long: (add entry, optional) first bar of a new calendar week AND position is long AND close < avg_price
Exit: long, high >= exit_all_level (close all open entries and cancel pending add entries)
Exit: long, (close < exit_all_level AND high >= layer_k + close * P/100, with P < P_all) OR (close >= exit_all_level AND high >= exit_all_level), evaluated for each open entry k (layer_1 for the first entry); closes one entry, FIFO (oldest open entry first)