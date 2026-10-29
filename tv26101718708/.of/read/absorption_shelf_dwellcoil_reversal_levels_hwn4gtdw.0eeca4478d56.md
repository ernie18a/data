Calculation: Dwell bands = divide price into fixed-tick levels; each chart bar adds equal total occupation time across the levels from its low through high. Keep a rolling lookback and subtract expired bars; mark levels at or above the configured percentile of all level occupation as hot, merge hot levels within the configured gap, and retain bands meeting the minimum width.
Calculation: Active shelf = a dwell band for which 1 − fast ATR / slow ATR meets the coil threshold and the configured fraction of recent chart-timeframe closes lies within the band expanded by the configured ATR buffer.
Calculation: Shelf approach = support approach if the close before the first band touch is at or above the dwell-weighted band midpoint; otherwise resistance approach. A touch occurs when the chart bar's high-low range overlaps the band.
Calculation: Has volume = positive sum of lower-timeframe bar volumes within the chart bar, falling back to chart-bar volume when no lower-timeframe data is available; evaluate on the confirmed chart bar.
Calculation: Volume measure = chart-bar volume, or, when time-of-day normalization is enabled, volume divided by its EMA for the same clock-time slot on prior sessions.
Calculation: Spread rank = percentile rank of chart-bar high − low over the configured chart-bar lookback. Volume rank = percentile rank of the volume measure over that lookback. Close position = (close − low) / (high − low), or 0.5 when high equals low. Prior-window high/low = highest high / lowest low over the configured number of preceding chart bars, excluding the current bar. Peak volume = highest volume measure over the lookback including the current bar.
Long: active shelf with support approach and at least one touch AND close > shelf high + configured flip distance × chart-timeframe ATR AND prior chart-bar low <= shelf high + configured flip distance × chart-timeframe ATR
Long: Has volume AND low <= prior-window low AND close position >= 0.65 AND volume rank >= 60
Long: Has volume AND close < prior close AND spread rank >= 60 AND volume rank >= 80 AND close position >= 0.45
Long: Has volume AND close < prior close AND volume measure >= peak volume AND spread rank >= 70
Long: Has volume AND close < prior close AND spread rank <= 35 AND volume rank <= 35
Short: active shelf with resistance approach and at least one touch AND close < shelf low − configured flip distance × chart-timeframe ATR AND prior chart-bar high >= shelf low − configured flip distance × chart-timeframe ATR
Short: Has volume AND high >= prior-window high AND close position <= 0.35 AND volume rank >= 60
Short: Has volume AND close > prior close AND volume measure >= peak volume AND spread rank >= 70
Short: Has volume AND close > prior close AND spread rank <= 35 AND volume rank <= 35