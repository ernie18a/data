Calculation: Bullish 3-line strike = the previous three candles are bearish, the immediately previous candle is bearish, and the current candle is bullish with a body larger than the previous candle’s body
Calculation: Bearish 3-line strike = the previous three candles are bullish, the immediately previous candle is bullish, and the current candle is bearish with a body larger than the previous candle’s body
Long: Bullish 3-line strike
Long: Bullish 3-line strike AND current volume > 1.5 × the 30-bar SMA of volume AND the shorter-lookback SMA of close > the longer-lookback SMA of close AND the configured session filter passes when enabled
Short: Bearish 3-line strike
Short: Bearish 3-line strike AND current volume > 1.5 × the 30-bar SMA of volume AND the shorter-lookback SMA of close < the longer-lookback SMA of close AND the configured session filter passes when enabled
Calculation: Long stop price = on entry, either current low minus the configured offset or entry price minus configured ATR multiple; while in an ATR trail mode, update each bar to the greater of the prior stop and current close minus configured ATR multiple
Calculation: Short stop price = on entry, either current high plus the configured offset or entry price plus configured ATR multiple; while in an ATR trail mode, update each bar to the lesser of the prior stop and current close plus configured ATR multiple
Calculation: Long take-profit price = entry price plus configured risk/reward multiple of entry price minus initial stop price; omit in ATR Trail mode
Calculation: Short take-profit price = entry price minus configured risk/reward multiple of initial stop price minus entry price; omit in ATR Trail mode
Exit: Long, low <= long stop price OR (a take-profit is set AND high >= long take-profit price)
Exit: Short, high >= short stop price OR (a take-profit is set AND low <= short take-profit price)