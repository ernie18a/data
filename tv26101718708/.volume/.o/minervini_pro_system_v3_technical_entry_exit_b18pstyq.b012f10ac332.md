Calculation: Trend template = close > 150-period SMA AND close > 200-period SMA AND 150-period SMA > 200-period SMA AND 200-period SMA > its value 20 bars earlier AND 50-period SMA > 150-period SMA AND 50-period SMA > 200-period SMA AND close > 50-period SMA AND close >= 75% of the highest high over 252 bars AND close >= 130% of the lowest low over 252 bars
Calculation: Relative strength = close / same-timeframe comparison-index close; strong when above its 50-period SMA and above its value 20 bars earlier
Calculation: VCP tightness = (highest high minus lowest low over the shorter lookback) < 55% of (highest high minus lowest low over the longer lookback) AND ATR as a percentage of close < its 50-period SMA AND absolute close change as a percentage of close < its 20-period SMA; the longer range lookback exceeds the shorter one
Calculation: Volume dry-up = 10-period SMA of volume < 50-period SMA of volume
Calculation: Not extended = (close - 50-period SMA) / 50-period SMA * 100 <= maximum extension AND > -3
Calculation: Market healthy = same-timeframe comparison-index close > its 50-period SMA AND > its 200-period SMA AND its 50-period SMA > its 200-period SMA
Calculation: Weekly trend = weekly close > weekly 10-period SMA AND weekly 10-period SMA > weekly 30-period SMA; use the current weekly bar, which may still be forming
Calculation: Pivot high = highest high over the pivot lookback, excluding the current bar
Calculation: Breakout = close > pivot high AND close > open
Calculation: Strong close = close > low + 60% * (high - low)
Calculation: Average volume = volume SMA over the average-volume lookback
Calculation: Common entry filter = trend template AND relative strength is strong AND VCP tightness AND not extended AND market healthy AND weekly trend
Calculation: Early trigger = highest high over the prior five bars
Calculation: Retest window = bars since the most recent breakout entry <= retest-window length
Calculation: Near pivot = low <= pivot high * (1 + retest tolerance / 100) AND close >= pivot high * (1 - retest tolerance / 100)
Long: Common entry filter AND (close > early trigger AND volume > average volume * early-volume multiplier AND prior bar had volume dry-up OR Breakout AND volume > average volume * breakout-volume multiplier AND strong close OR retest window AND near pivot AND close > 50-period SMA AND close > open)
Calculation: Active stop = at entry, lowest low over the initial-stop lookback; thereafter, the greater of the active stop and lowest low over the trailing-stop lookback
Calculation: Active pivot = pivot high at entry
Exit: Long, close < active stop OR (close < active pivot AND close < 50-period SMA) OR (close < 21-period EMA AND close < prior close) OR (close < open AND volume > average volume * 1.5 AND close < prior close)