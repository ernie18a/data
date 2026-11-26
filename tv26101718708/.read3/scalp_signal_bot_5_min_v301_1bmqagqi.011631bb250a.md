Calculation: Low source = low for wick structure, otherwise min(open, close)
Calculation: High source = high for wick structure, otherwise max(open, close)
Calculation: Low-sweep event = low source < Lowest(low source, sweep lookback)[1]
Calculation: High-sweep event = high source > Highest(high source, sweep lookback)[1]
Calculation: Latest low-sweep price = low source at the most recent low-sweep event
Calculation: Latest high-sweep price = high source at the most recent high-sweep event
Calculation: Low-sweep age = chart bars since the most recent low-sweep event
Calculation: High-sweep age = chart bars since the most recent high-sweep event
Calculation: Any-sweep age = chart bars since the most recent low- or high-sweep event
Calculation: Low-sweep reclaim = close > latest low-sweep price + buffer in same-bar reclaim mode; otherwise close[1] <= latest low-sweep price + buffer AND close > latest low-sweep price + buffer
Calculation: High-sweep reclaim = close < latest high-sweep price - buffer in same-bar reclaim mode; otherwise close[1] >= latest high-sweep price - buffer AND close < latest high-sweep price - buffer
Calculation: Low-sweep confirmation = low-sweep age <= maximum sweep age AND low-sweep reclaim
Calculation: High-sweep confirmation = high-sweep age <= maximum sweep age AND high-sweep reclaim
Calculation: Low-sweep count = rolling count of low-sweep events over the cluster lookback
Calculation: High-sweep count = rolling count of high-sweep events over the cluster lookback
Calculation: Buffer = ATR(ATR lookback) * ATR multiplier when ATR buffering is selected; otherwise minimum price increment * tick buffer
Calculation: Long stop = latest low-sweep price - buffer if one exists; otherwise most recent confirmed PivotLow(low source, pivot lookback, pivot lookback) - buffer
Calculation: Short stop = latest high-sweep price + buffer if one exists; otherwise most recent confirmed PivotHigh(high source, pivot lookback, pivot lookback) + buffer
Calculation: Long target = close + (close - long stop) * R multiple when R-based targeting is selected; otherwise close * (1 + fixed target percentage / 100)
Calculation: Short target = close - (short stop - close) * R multiple when R-based targeting is selected; otherwise close * (1 - fixed target percentage / 100)
Calculation: Latest sweep volume ratio = volume / SMA(volume, volume lookback) on the most recent low- or high-sweep bar; undefined if the SMA is unavailable or zero
Long: low-sweep event
Long: low-sweep confirmation
Short: high-sweep event
Short: high-sweep confirmation
Long: longs enabled AND close > most recent confirmed PivotHigh(high source, pivot lookback, pivot lookback) AND (low-sweep filter disabled OR low-sweep confirmation) AND (trend filter disabled OR long trend permission enabled AND close > EMA(close, trend lookback)) AND (sweep entry delay disabled OR any-sweep age > delay bars) AND (sweep clustering disabled OR high-sweep count < minimum cluster count) AND (reclaim suppression disabled OR no bar within maximum sweep age had high-sweep count >= minimum cluster count AND high-sweep reclaim) AND (relative-volume filter disabled OR SMA(volume, volume lookback) unavailable OR volume > SMA(volume, volume lookback) * relative-volume threshold) AND (sweep-volume filter disabled OR latest sweep volume ratio undefined OR latest sweep volume ratio >= sweep-volume threshold) AND (recent-time window disabled OR datetime >= current time - window duration) AND (cooldown disabled OR no prior position close OR bars since the most recent flat transition >= cooldown bars) AND (close-confirmation mode disabled OR chart bar is confirmed)
Short: shorts enabled AND close < most recent confirmed PivotLow(low source, pivot lookback, pivot lookback) AND (trend filter disabled OR short trend permission enabled AND close < EMA(close, trend lookback)) AND (sweep entry delay disabled OR any-sweep age > delay bars) AND (sweep clustering disabled OR low-sweep count < minimum cluster count) AND (reclaim suppression disabled OR no bar within maximum sweep age had low-sweep count >= minimum cluster count AND low-sweep reclaim) AND (relative-volume filter disabled OR SMA(volume, volume lookback) unavailable OR volume > SMA(volume, volume lookback) * relative-volume threshold) AND (sweep-volume filter disabled OR latest sweep volume ratio undefined OR latest sweep volume ratio >= sweep-volume threshold) AND (recent-time window disabled OR datetime >= current time - window duration) AND (cooldown disabled OR no prior position close OR bars since the most recent flat transition >= cooldown bars) AND (close-confirmation mode disabled OR chart bar is confirmed)
Exit: long, low <= long stop calculated at entry (or current long stop when drifting exits are enabled) OR high >= long target calculated at entry (or current long target when drifting exits are enabled)
Exit: short, high >= short stop calculated at entry (or current short stop when drifting exits are enabled) OR low <= short target calculated at entry (or current short target when drifting exits are enabled)