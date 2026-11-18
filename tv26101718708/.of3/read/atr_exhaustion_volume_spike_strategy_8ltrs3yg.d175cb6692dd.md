Calculation: latest confirmed pivot high = most recent confirmed Pivot High(high, left pivot lookback, right pivot lookback)
Calculation: latest confirmed pivot low = most recent confirmed Pivot Low(low, left pivot lookback, right pivot lookback)
Calculation: long stop = min(latest confirmed pivot low on entry-signal bar, entry-signal bar low)
Calculation: long target = entry-signal bar close + (entry-signal bar close - long stop) * reward-to-risk ratio
Calculation: short stop = max(latest confirmed pivot high on entry-signal bar, entry-signal bar high)
Calculation: short target = entry-signal bar close - (short stop - entry-signal bar close) * reward-to-risk ratio
Long: low <= latest confirmed pivot low * (1 + level proximity) AND low >= latest confirmed pivot low * (1 - level proximity) AND latest confirmed pivot high - low > ATR(ATR lookback) * exhaustion multiplier AND volume > SMA(volume, volume lookback) * volume spike multiplier AND (close > open OR close > high[1])
Long: flat AND low <= latest confirmed pivot low * (1 + level proximity) AND low >= latest confirmed pivot low * (1 - level proximity) AND latest confirmed pivot high - low > ATR(ATR lookback) * exhaustion multiplier AND volume > SMA(volume, volume lookback) * volume spike multiplier AND (close > open OR close > high[1]) AND close > long stop
Short: high >= latest confirmed pivot high * (1 - level proximity) AND high <= latest confirmed pivot high * (1 + level proximity) AND close - latest confirmed pivot low > ATR(ATR lookback) * exhaustion multiplier AND volume > SMA(volume, volume lookback) * volume spike multiplier AND (close < open OR close < low[1])
Short: flat AND high >= latest confirmed pivot high * (1 - level proximity) AND high <= latest confirmed pivot high * (1 + level proximity) AND close - latest confirmed pivot low > ATR(ATR lookback) * exhaustion multiplier AND volume > SMA(volume, volume lookback) * volume spike multiplier AND (close < open OR close < low[1]) AND close < short stop
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target