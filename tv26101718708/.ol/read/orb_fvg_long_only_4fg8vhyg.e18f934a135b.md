Calculation: Opening-range high = highest high during the configured opening-range window, fixed when that window ends
Calculation: Opening-range low = lowest low during the configured opening-range window, fixed when that window ends
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2
Calculation: Prior-day close position = (prior completed daily close - prior completed daily low) / (prior completed daily high - prior completed daily low)
Calculation: Bearish-day streak = consecutive completed daily bars whose close is in the lower portion of that day's high-low range
Calculation: Bullish FVG = current low > high two bars earlier
Calculation: Stop price = configured choice of opening-range low, opening-range midpoint, or entry price minus a configured ATR-based distance
Calculation: Risk = entry price - stop price
Calculation: Second profit target = entry price + risk × configured reward multiple
Long: opening range has ended AND close > opening-range high AND prior close <= opening-range high AND bar time is within the configured trade window AND (daily-bias filter disabled OR close > current daily open) AND (daily trend filter disabled OR close > current daily EMA) AND (trend-day filter disabled OR prior-day close position is in the upper half of its range) AND (loss-streak filter disabled OR bearish-day streak is below its configured limit) AND (one-trade-per-day limit disabled OR no long has been signaled today) AND (FVG confluence disabled OR a bullish FVG formed within the configured lookback) AND (volume filter disabled OR volume > its configured multiple of a rolling average) AND bar is confirmed
Exit: long, low <= stop price OR high >= second profit target