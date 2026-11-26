Calculation: Bullish sweep = low < latest confirmed PivotLow(low, swing lookback, swing lookback) AND close > the same pivot low OR low < low(T1, last completed bar), sampled on chart bars, AND close > that low
Calculation: Bearish sweep = high > latest confirmed PivotHigh(high, swing lookback, swing lookback) AND close < the same pivot high OR high > high(T1, last completed bar), sampled on chart bars, AND close < that high
Calculation: Bullish FVG event = low > high[FVG lag] AND low - high[FVG lag] > ATR(ATR lookback) * FVG size multiplier; FVG lag is longer than the prior-bar lag
Calculation: Bearish FVG event = high < low[FVG lag] AND low[FVG lag] - high > ATR(ATR lookback) * FVG size multiplier
Calculation: Latest bullish FVG zone = lower bound high[FVG lag] and upper bound low on the most recent bullish FVG event, retained until replaced when FVG generation is enabled
Calculation: Latest bearish FVG zone = lower bound high and upper bound low[FVG lag] on the most recent bearish FVG event, retained until replaced when FVG generation is enabled
Calculation: Bullish institutional zone event = close > high[prior-bar lag] AND close - open > ATR(ATR lookback) * zone displacement multiplier AND close[prior-bar lag] < open[prior-bar lag]
Calculation: Bearish institutional zone event = close < low[prior-bar lag] AND open - close > ATR(ATR lookback) * zone displacement multiplier AND close[prior-bar lag] > open[prior-bar lag]
Calculation: Latest bullish institutional zone = lower bound low[prior-bar lag] and upper bound max(open[prior-bar lag], close[prior-bar lag]) on the most recent bullish institutional zone event, retained until replaced when zone generation is enabled
Calculation: Latest bearish institutional zone = lower bound min(open[prior-bar lag], close[prior-bar lag]) and upper bound high[prior-bar lag] on the most recent bearish institutional zone event, retained until replaced when zone generation is enabled
Calculation: Premium/discount midpoint = (highest(high, range lookback) + lowest(low, range lookback)) / 2
Calculation: Long initial stop = signal bar low when swing stops are enabled; otherwise entry price - ATR(ATR lookback) * stop-distance multiplier
Calculation: Short initial stop = signal bar high when swing stops are enabled; otherwise entry price + ATR(ATR lookback) * stop-distance multiplier
Calculation: Long initial risk = entry price - long initial stop
Calculation: Short initial risk = short initial stop - entry price
Long: close > latest confirmed PivotHigh(high, swing lookback, swing lookback)
Short: close < latest confirmed PivotLow(low, swing lookback, swing lookback)
Long: Bullish sweep
Short: Bearish sweep
Long: Bullish FVG event
Short: Bearish FVG event
Long: Bullish institutional zone event
Short: Bearish institutional zone event
Long: longs enabled AND (single-trade mode disabled OR position flat) AND at least one Bullish sweep occurred on the current or prior sweep-lookback chart bars AND (current bar overlaps the latest bullish institutional zone OR current bar overlaps the latest bullish FVG zone) AND close > open AND (confirmation-break requirement disabled OR close > high[prior-bar lag]) AND (premium/discount filter disabled OR close < Premium/discount midpoint) AND (trend filter disabled OR EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback))
Short: shorts enabled AND (single-trade mode disabled OR position flat) AND at least one Bearish sweep occurred on the current or prior sweep-lookback chart bars AND (current bar overlaps the latest bearish institutional zone OR current bar overlaps the latest bearish FVG zone) AND close < open AND (confirmation-break requirement disabled OR close < low[prior-bar lag]) AND (premium/discount filter disabled OR close > Premium/discount midpoint) AND (trend filter disabled OR EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback))
Exit: Long, low <= long initial stop OR (breakeven enabled AND high >= entry price + long initial risk * breakeven trigger multiple AND low <= entry price) OR (trailing stop enabled AND low <= close - ATR(ATR lookback) * trailing-stop multiplier) OR high >= entry price + long initial risk * reward multiple
Exit: Short, high >= short initial stop OR (breakeven enabled AND low <= entry price - short initial risk * breakeven trigger multiple AND high >= entry price) OR (trailing stop enabled AND high >= close + ATR(ATR lookback) * trailing-stop multiplier) OR low <= entry price - short initial risk * reward multiple