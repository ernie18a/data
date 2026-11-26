Calculation: InsideBarDirection = bullish when high < high[1] AND low > low[1] AND close >= open; bearish when high < high[1] AND low > low[1] AND close < open; neither otherwise
Calculation: AnyWithinLookback(x, n) = true if x[k] is true for any integer k from 0 through n
Long: InsideBarDirection = bullish
Short: InsideBarDirection = bearish
Long: AnyWithinLookback(InsideBarDirection = bullish, inside-bar lookback) AND long breakout source > high[inside-bar lookback] AND EMA source > EMA(EMA source, EMA lookback) AND (ADX filter disabled OR ADX(high, low, close, DI lookback, ADX smoothing lookback) > ADX threshold) AND long entries enabled AND position side is not long
Short: AnyWithinLookback(InsideBarDirection = bearish, inside-bar lookback) AND short breakdown source < low[inside-bar lookback] AND EMA source < EMA(EMA source, EMA lookback) AND (ADX filter disabled OR ADX(high, low, close, DI lookback, ADX smoothing lookback) > ADX threshold) AND short entries enabled AND position side is not short
Exit: long, close < entry price * (1 - stop-loss percentage)
Exit: short, close > entry price * (1 + stop-loss percentage)
Exit: long, high >= entry price * (1 + first profit target percentage)
Exit: long, high >= entry price * (1 + second profit target percentage)
Exit: long, high >= entry price * (1 + third profit target percentage)
Exit: long, high >= entry price * (1 + fourth profit target percentage)
Exit: short, low <= entry price * (1 - first profit target percentage)
Exit: short, low <= entry price * (1 - second profit target percentage)
Exit: short, low <= entry price * (1 - third profit target percentage)
Exit: short, low <= entry price * (1 - fourth profit target percentage)