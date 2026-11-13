Calculation: SAR_slow = Parabolic SAR with a smaller acceleration step and a smaller maximum acceleration than SAR_fast, on the chart timeframe, last completed bar
Calculation: SAR_fast = Parabolic SAR with a larger acceleration step and a larger maximum acceleration than SAR_slow, on the chart timeframe, last completed bar
Long: evaluated once per new bar on the last completed bar; no long position is open AND SAR_slow < close AND SAR_fast < close AND bar time is inside the allowed intraday trading window
Short: evaluated once per new bar on the last completed bar; no short position is open AND SAR_slow > close AND SAR_fast > close AND bar time is inside the allowed intraday trading window
Exit: long, SAR_fast > close (last completed bar) AND bar time is inside the allowed intraday trading window
Exit: short, SAR_fast < close (last completed bar) AND bar time is inside the allowed intraday trading window
Exit: long, price <= entry price - k1 * ATR (ATR on chart timeframe, last completed bar at entry time, fixed from entry)
Exit: short, price >= entry price + k1 * ATR (ATR on chart timeframe, last completed bar at entry time, fixed from entry)
Exit: long, optional trailing stop: price <= trailing stop, where trailing stop = price - k2 * ATR (chart timeframe, last completed bar) and only ratchets upward
Exit: short, optional trailing stop: price >= trailing stop, where trailing stop = price + k2 * ATR (chart timeframe, last completed bar) and only ratchets downward
Exit: long, partial exit of half the position once, when price - entry price > k1 * ATR (the initial stop distance)
Exit: short, partial exit of half the position once, when entry price - price > k1 * ATR (the initial stop distance)