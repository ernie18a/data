Calculation: Bar delta = sum of signed volumes of all completed lower-timeframe bars within the chart bar, with volume positive when close > open, negative when close < open, and zero when close = open; if no lower-timeframe bars are available, use the chart bar's signed volume. If the selected timeframe is not lower than the chart timeframe, use the chart bar's signed volume.
Calculation: Cumulative volume delta = running sum of bar delta from the beginning of the data.
Calculation: Close position = (close - low) / (high - low) when high > low; otherwise 0.5.
Calculation: ATR percentile rank = percentage of ATR values in its lookback window that are less than or equal to the current ATR.
Calculation: Bearish exhaustion = high >= highest high over the current lookback including this bar AND cumulative volume delta < highest cumulative volume delta over the same-length lookback ending on the previous bar AND bar delta > 0 AND close position < threshold AND ATR percentile rank >= minimum percentile.
Calculation: Bullish exhaustion = low <= lowest low over the current lookback including this bar AND cumulative volume delta > lowest cumulative volume delta over the same-length lookback ending on the previous bar AND bar delta < 0 AND close position > 1 - threshold AND ATR percentile rank >= minimum percentile.
Calculation: Pending setup = the most recent exhaustion bar's direction, high, low, midpoint and bar index. On each bar, a new bearish exhaustion replaces any pending setup; otherwise a new bullish exhaustion replaces it. Expire the setup when its age exceeds the confirmation window. Evaluate confirmation before cancelling a bearish setup when high > its high or a bullish setup when low < its low. Clear the setup after an entry order.
Calculation: Trade levels = for a long, stop = bullish setup low - ATR on the confirmation bar × stop buffer and target = confirmation close + target multiple × (confirmation close - stop); for a short, stop = bearish setup high + ATR on the confirmation bar × stop buffer and target = confirmation close - target multiple × (stop - confirmation close). Fix these levels at confirmation. Entry and market-exit orders fill at the next bar's open; stop and target orders are submitted while the position is open and use intrabar prices.
Long: Bullish exhaustion.
Short: Bearish exhaustion.
Long: Position is flat AND pending setup is bullish AND setup age > 0 AND setup age <= confirmation window AND close > setup midpoint AND close - stop > 0.
Short: Position is flat AND pending setup is bearish AND setup age > 0 AND setup age <= confirmation window AND close < setup midpoint AND stop - close > 0.
Exit: Long, low <= stop OR high >= target.
Exit: Short, high >= stop OR low <= target.
Exit: Long, close < entry price AND bar delta < 0 for at least the specified number of consecutive bars since entry.
Exit: Short, close > entry price AND bar delta > 0 for at least the specified number of consecutive bars since entry.
Exit: Long, bars elapsed since the entry signal >= maximum holding period.
Exit: Short, bars elapsed since the entry signal >= maximum holding period.