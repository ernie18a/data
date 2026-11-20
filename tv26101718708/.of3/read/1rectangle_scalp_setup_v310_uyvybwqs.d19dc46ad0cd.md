Calculation: Source OHLC = Heikin Ashi OHLC or chart OHLC, according to the source setting
Calculation: Rectangle size (%) = (highest(source high, consolidation lookback) - lowest(source low, consolidation lookback)) / source close * 100
Calculation: Stop buffer = stop buffer percent / 100 * entry price when the configured basis is price, or stop buffer percent / 100 * (highest(source high, consolidation lookback)[1] - lowest(source low, consolidation lookback)[1]) when the basis is rectangle
Calculation: Long stop = lowest(source low, consolidation lookback)[1] - stop buffer, fixed at entry
Calculation: Short stop = highest(source high, consolidation lookback)[1] + stop buffer, fixed at entry
Calculation: Long target 2 = entry price + (entry price - long stop) * target-2 risk/reward, fixed at entry
Calculation: Short target 2 = entry price - (short stop - entry price) * target-2 risk/reward, fixed at entry
Long: rectangle size (%)[1] < maximum range size AND source close > highest(source high, consolidation lookback)[1] AND source close[1] <= highest(source high, consolidation lookback)[1] AND no prior signal or the most recent signal was short AND (session filter is disabled OR datetime is within the configured UTC+3 session and selected days)
Short: rectangle size (%)[1] < maximum range size AND source close < lowest(source low, consolidation lookback)[1] AND source close[1] >= lowest(source low, consolidation lookback)[1] AND no prior signal or the most recent signal was long AND (session filter is disabled OR datetime is within the configured UTC+3 session and selected days)
Exit: Long, after the entry bar, source low <= long stop OR source high >= long target 2
Exit: Short, after the entry bar, source high >= short stop OR source low <= short target 2