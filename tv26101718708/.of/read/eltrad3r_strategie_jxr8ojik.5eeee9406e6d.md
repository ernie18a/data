Calculation: ConsolRange = for each day, ConsolHigh = highest high and ConsolLow = lowest low of the chart-timeframe bars inside a fixed intraday consolidation time window; range is final once the window has ended
Calculation: EMA = exponential moving average of close on the chart timeframe, current bar
Calculation: Stop = at entry, the previous bar's low for a long, or the previous bar's high for a short; fixed for the life of the trade
Calculation: Target = at entry, long: entry price + MinRR * (entry price - Stop); short: entry price - MinRR * (Stop - entry price), where MinRR is a fixed reward-to-risk multiple
Long: current bar is in a trading time window that starts at or after the consolidation window ends, AND the day's ConsolRange exists, AND no position is open, AND number of entries already taken today < daily maximum, AND close > ConsolHigh AND close > EMA AND close > previous bar's low
Short: current bar is in a trading time window that starts at or after the consolidation window ends, AND the day's ConsolRange exists, AND no position is open, AND number of entries already taken today < daily maximum, AND close < ConsolLow AND close < EMA AND close < previous bar's high
Exit: long, close < EMA OR low <= Stop OR high >= Target
Exit: short, close > EMA OR high >= Stop OR low <= Target