Calculation: Last swing high = the most recent non-NA PivotHigh(high, swing length, swing length)
Calculation: Last swing low = the most recent non-NA PivotLow(low, swing length, swing length)
Calculation: Bullish BOS = close crosses above Last swing high AND (displacement filter off OR (close > open AND abs(close - open) >= ATR(ATR length) * displacement multiple))
Calculation: Bearish BOS = close crosses below Last swing low AND (displacement filter off OR (close < open AND abs(close - open) >= ATR(ATR length) * displacement multiple))
Calculation: Trend state = 1 if Bullish BOS, else -1 if Bearish BOS, else Trend state[1] (0 before any BOS)
Calculation: Swing-low pools = list of PivotLow(low, swing length, swing length) values; each new value is appended, the oldest is dropped when the list exceeds max pools, and a value is dropped when its pivot bar is more than pool max age bars before the current bar or when Low sweep takes it
Calculation: Swing-high pools = list of PivotHigh(high, swing length, swing length) values; each new value is appended, the oldest is dropped when the list exceeds max pools, and a value is dropped when its pivot bar is more than pool max age bars before the current bar or when High sweep takes it
Calculation: Low sweep = (low < p AND close > p) for some p in Swing-low pools; the newest such p is then removed from Swing-low pools
Calculation: High sweep = (high > p AND close < p) for some p in Swing-high pools; the newest such p is then removed from Swing-high pools
Calculation: HTF bias = 1 if close(T1, last completed bar) > SMA(close, HTF MA length, T1, last completed bar), -1 if less, else 0
Calculation: Long confirmed = Bullish BOS AND (Low sweep was true on some bar s with current bar - s <= sweep timeout, Trend state on s <= 0, and no Bearish BOS on bars s through current bar) AND (HTF filter off OR HTF bias = 1)
Calculation: Short confirmed = Bearish BOS AND (High sweep was true on some bar s with current bar - s <= sweep timeout, Trend state on s >= 0, and no Bullish BOS on bars s through current bar) AND (HTF filter off OR HTF bias = -1)
Calculation: Bullish OB = (high, low) of the most recent bar before the current bar, within OB lookback bars, with close < open; NA if none
Calculation: Bearish OB = (high, low) of the most recent bar before the current bar, within OB lookback bars, with close > open; NA if none
Calculation: Long OB = Bullish OB on the most recent Long confirmed bar where Bullish OB is not NA
Calculation: Short OB = Bearish OB on the most recent Short confirmed bar where Bearish OB is not NA
Calculation: Long zone = Bullish OB of the Long confirmed bar c behind the latest Long freeze; a Long freeze at bar f occurs for each Long confirmed bar c with non-NA Bullish OB, where f = c if FVG filter off, else f = the first bar k with k - c <= FVG window + 1, low > high[2], and no Bearish BOS on bars c through k; NA before the first freeze
Calculation: Short zone = Bearish OB of the Short confirmed bar c behind the latest Short freeze; a Short freeze at bar f occurs for each Short confirmed bar c with non-NA Bearish OB, where f = c if FVG filter off, else f = the first bar k with k - c <= FVG window + 1, high < low[2], and no Bullish BOS on bars c through k; NA before the first freeze
Calculation: Long touch bar = the first bar k >= f with k - f <= touch timeout, high >= Long zone bottom, low <= Long zone top, and no Bearish BOS on bars f through k; f = freeze bar of Long zone
Calculation: Short touch bar = the first bar k >= f with k - f <= touch timeout, low <= Short zone top, high >= Short zone bottom, and no Bullish BOS on bars f through k; f = freeze bar of Short zone
Calculation: Long retest confirmed = Long touch bar k exists with current bar - k <= confirm timeout, no Bearish BOS on bars k through current bar, the current bar satisfies the confirmation mode (None: always true; Rejection: close > open AND min(open, close) - low > abs(close - open) * rejection wick ratio; Engulfing: close > open AND close[1] < open[1] AND open <= close[1] AND close >= open[1]; Close back through zone: close > Long zone top; Break touch high: close > high of Long touch bar), and no earlier bar from k through the previous bar satisfied the confirmation mode
Calculation: Short retest confirmed = Short touch bar k exists with current bar - k <= confirm timeout, no Bullish BOS on bars k through current bar, the current bar satisfies the confirmation mode (None: always true; Rejection: close < open AND high - max(open, close) > abs(close - open) * rejection wick ratio; Engulfing: close < open AND close[1] > open[1] AND open >= close[1] AND close <= open[1]; Close back through zone: close < Short zone bottom; Break touch low: close < low of Short touch bar), and no earlier bar from k through the previous bar satisfied the confirmation mode
Long: (OB retest not required AND Long confirmed) OR (OB retest required AND Long retest confirmed)
Long: Trend state = 1
Long: HTF filter on AND HTF bias = 1
Short: (OB retest not required AND Short confirmed) OR (OB retest required AND Short retest confirmed)
Short: Trend state = -1
Short: HTF filter on AND HTF bias = -1
Calculation: Long stop zone bottom = bottom of Long zone, set to NA at each Long entry, if OB retest required; else bottom of Long OB
Calculation: Long stop = Long stop zone bottom - ATR(ATR length) * stop buffer if stop method is Order Block and Long stop zone bottom is not NA; close * (1 - stop pct / 100) if stop method is Percent; else close - ATR(ATR length) * ATR stop multiple
Calculation: Long target = close * (1 + target pct / 100) if stop method is Percent; else the nearest Swing-high pool above close if target method is nearest liquidity pool and one exists; else close + target R multiple * (close - Long stop)
Calculation: Long initial stop = Long stop on the Long entry bar
Calculation: Long breakeven reached = breakeven move AND high >= entry price + (entry price - Long initial stop) on some bar from the Long entry bar through current bar
Calculation: Long active stop = entry price if Long breakeven reached, else Long initial stop
Exit: Long, low <= Long active stop OR high >= Long target
Calculation: Short stop zone top = top of Short zone, set to NA at each Short entry, if OB retest required; else top of Short OB
Calculation: Short stop = Short stop zone top + ATR(ATR length) * stop buffer if stop method is Order Block and Short stop zone top is not NA; close * (1 + stop pct / 100) if stop method is Percent; else close + ATR(ATR length) * ATR stop multiple
Calculation: Short target = close * (1 - target pct / 100) if stop method is Percent; else the nearest Swing-low pool below close if target method is nearest liquidity pool and one exists; else close - target R multiple * (Short stop - close)
Calculation: Short initial stop = Short stop on the Short entry bar
Calculation: Short breakeven reached = breakeven move AND low <= entry price - (Short initial stop - entry price) on some bar from the Short entry bar through current bar
Calculation: Short active stop = entry price if Short breakeven reached, else Short initial stop
Exit: Short, high >= Short active stop OR low <= Short target