Calculation: RefRange = high and low (RefHigh, RefLow) of the last completed higher-timeframe bar that starts at a fixed time of day; available only after that bar completes, recomputed each day
Calculation: UpperFib = RefHigh - a*(RefHigh-RefLow); LowerFib = RefHigh - b*(RefHigh-RefLow); 0 < a < b < 1
Calculation: SetupDir = direction of the first close of the day (after RefRange is available) outside RefRange: up if close > RefHigh, down if close < RefLow; once set it stays fixed for the rest of the day, and any later opposite breakout is ignored
Calculation: Entry price = UpperFib for long, LowerFib for short; long stop = LowerFib, long target = entry + k*(entry - LowerFib); short stop = UpperFib, short target = entry - k*(UpperFib - entry); k > 0
Long: SetupDir is up (it may be set on the current bar) AND no trade has been entered yet today AND low <= UpperFib AND close > open
Short: SetupDir is down (it may be set on the current bar) AND no trade has been entered yet today AND high >= LowerFib AND close < open
Exit: long, high >= long target OR low <= long stop (target checked before stop; evaluated from the entry bar onward)
Exit: short, low <= short target OR high >= short stop (target checked before stop; evaluated from the entry bar onward)