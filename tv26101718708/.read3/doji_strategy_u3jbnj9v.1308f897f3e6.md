Calculation: Doji = abs(open - close) <= (high - low) * doji-size
Calculation: Long-body bar = abs(close - open) / (high - low) > long-candle ratio
Calculation: Buy-stop price on setup bar = if Long-body bar[1] AND (high[1] - low[1]) > (high - low) then high else max(high, high[1])
Calculation: Sell-stop price on setup bar = if Long-body bar[1] AND (high[1] - low[1]) > (high - low) then low else min(low, low[1])
Long: A pending buy stop created on a Doji bar where the volume filter is off OR volume > EMA(volume, volume lookback) triggers when high >= that setup bar's Buy-stop price
Short: A pending sell stop created on a Doji bar where the volume filter is off OR volume > EMA(volume, volume lookback) triggers when low <= that setup bar's Sell-stop price
Exit: Long, high >= entry price + take-profit OR stop loss enabled AND low <= entry price - stop-loss
Exit: Short, low <= entry price - take-profit OR stop loss enabled AND high >= entry price + stop-loss