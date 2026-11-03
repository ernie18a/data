Calculation: Smoothed candle = apply a first moving average and then a second independently parameterized moving average to each of open and close. If abs(open - close) <= gap threshold, replace the smoothed open with the preceding bar's smoothed close.
Long: Chart-timeframe smoothed candle close > smoothed candle open
Short: Chart-timeframe smoothed candle close < smoothed candle open
Long: On the selected higher or lower timeframe, the last completed smoothed candle close > smoothed candle open AND the preceding smoothed candle close <= smoothed candle open
Short: On the selected higher or lower timeframe, the last completed smoothed candle close < smoothed candle open AND the preceding smoothed candle close >= smoothed candle open
Exit: long, on the selected higher or lower timeframe, the last completed smoothed candle close < smoothed candle open OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, on the selected higher or lower timeframe, the last completed smoothed candle close > smoothed candle open OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance