Calculation: 20/80 levels = nearest step-based price levels offset by 20% and 80% of the price step, respectively, rounding the level index to the nearest integer
Calculation: Displacement = current bar high−low > the highest high−low of the preceding five chart-timeframe bars
Calculation: Bullish FVG = current low > high two chart-timeframe bars ago; bearish FVG = current high < low two chart-timeframe bars ago
Calculation: Session range high/low = maximum high/minimum low during that session's range window
Calculation: Consecutive up/down candles = consecutive one-minute closes higher/lower than the preceding one-minute close; use one-minute bars, which may be higher or lower than the chart timeframe, including the current bar as it forms
Calculation: NY midnight open = open of the first bar of the NY trading day
Calculation: First-hour consolidation = first NY hour's high−low < configured multiplier × ATR(14) on the chart timeframe; freeze this result for the rest of the day
Long: During the London or NY trade window, that session's low has been swept (current low < its range low after at least the configured number of consecutive down candles) AND current low ≤ nearest 20% level AND current close > that level AND (displacement filter disabled OR Displacement) AND (FVG filter disabled OR Bullish FVG)
Long: During the London or NY trade window, that session's low is swept after at least the configured number of consecutive down candles AND current close < current open
Long: Daily close > daily EMA(50) AND (weekly filter disabled OR daily close > weekly EMA(20)) AND current chart-timeframe close < NY midnight open AND NOT First-hour consolidation; use the latest available daily and weekly bars, which may still be forming
Long: Daily close > daily EMA(50); use the latest available daily bar, which may still be forming
Short: During the London or NY trade window, that session's high has been swept (current high > its range high after at least the configured number of consecutive up candles) AND current high ≥ nearest 80% level AND current close < that level AND (displacement filter disabled OR Displacement) AND (FVG filter disabled OR Bearish FVG)
Short: During the London or NY trade window, that session's high is swept after at least the configured number of consecutive up candles AND current close > current open
Short: Daily close < daily EMA(50) AND (weekly filter disabled OR daily close < weekly EMA(20)) AND current chart-timeframe close > NY midnight open AND NOT First-hour consolidation; use the latest available daily and weekly bars, which may still be forming
Short: Daily close ≤ daily EMA(50); use the latest available daily bar, which may still be forming