Calculation: Chart fast EMA = EMA(configured price field, fast lookback)
Calculation: Chart slow EMA = EMA(configured price field, slow lookback)
Calculation: Chart trend EMA = EMA(configured price field, trend lookback)
Calculation: T1 fast EMA = EMA(configured price field, fast lookback, T1, last completed bar; value read on chart bars)
Calculation: T1 slow EMA = EMA(configured price field, slow lookback, T1, last completed bar; value read on chart bars)
Calculation: RSI = RSI(configured price field, RSI lookback)
Calculation: VWAP = VWAP(hlc3)
Calculation: ADX = ADX(high, low, close, ADX lookback, ADX lookback)
Calculation: Volume average = SMA(volume, volume lookback)
Calculation: ATR = ATR(ATR lookback)
Calculation: Opening-range lookback = max(one chart bar, round(configured opening-range duration / chart-bar duration))
Calculation: Long confluence score = each true ordinary condition contributes the shared ordinary score weight, and a true T1 fast EMA > T1 slow EMA condition contributes the separate T1 score weight; ordinary conditions are Chart fast EMA > Chart slow EMA, close > Chart trend EMA, RSI > midpoint AND RSI < upper bound, close > open, close > VWAP, ADX > ADX threshold, and volume > Volume average
Calculation: Short confluence score = each true ordinary condition contributes the shared ordinary score weight, and a true T1 fast EMA < T1 slow EMA condition contributes the separate T1 score weight; ordinary conditions are Chart fast EMA < Chart slow EMA, close < Chart trend EMA, RSI < midpoint AND RSI > lower bound, close < open, close < VWAP, ADX > ADX threshold, and volume > Volume average
Calculation: Long initial stop = if structure stop is disabled, entry price - ATR at entry * stop ATR multiple; otherwise let candidate = max(entry price - ATR at entry * stop ATR multiple, lowest low across the current and preceding swing-lookback bars - ATR at entry * structure buffer multiple), then use entry price - ATR at entry * minimum stop-distance multiple if abs(entry price - candidate) < ATR at entry * minimum stop-distance multiple, else candidate
Calculation: Short initial stop = if structure stop is disabled, entry price + ATR at entry * stop ATR multiple; otherwise let candidate = min(entry price + ATR at entry * stop ATR multiple, highest high across the current and preceding swing-lookback bars + ATR at entry * structure buffer multiple), then use entry price + ATR at entry * minimum stop-distance multiple if abs(entry price - candidate) < ATR at entry * minimum stop-distance multiple, else candidate
Calculation: Initial risk = abs(entry price - the initial stop for the position side)
Calculation: Long target 1 = entry price + initial risk * target 1 multiple
Calculation: Long target 2 = entry price + initial risk * target 2 multiple
Calculation: Short target 1 = entry price - initial risk * target 1 multiple
Calculation: Short target 2 = entry price - initial risk * target 2 multiple
Calculation: Long trailing stop starts at the long initial stop; on each confirmed bar while managing a long position, if high >= Long target 1 and target 1 has not previously been hit, mark target 1 hit and, if trailing is enabled, set the stop to entry price; then if high >= Long target 2 and target 2 has not previously been hit, mark target 2 hit and, if trailing is enabled, set the stop to Long target 1
Calculation: Short trailing stop starts at the short initial stop; on each confirmed bar while managing a short position, if low <= Short target 1 and target 1 has not previously been hit, mark target 1 hit and, if trailing is enabled, set the stop to entry price; then if low <= Short target 2 and target 2 has not previously been hit, mark target 2 hit and, if trailing is enabled, set the stop to Short target 1
Long: Chart fast EMA > Chart slow EMA
Short: Chart fast EMA <= Chart slow EMA
Long: chart bar is confirmed AND (session filter is disabled OR bar time is within the configured session) AND T1 fast EMA > T1 slow EMA AND Chart fast EMA > Chart slow EMA AND close > Chart trend EMA AND close > Chart fast EMA AND RSI > midpoint AND RSI < upper bound AND Long confluence score >= confluence threshold AND (VWAP filter is disabled OR close > VWAP) AND (opening-range filter is disabled OR (opening range is ready after the opening-range lookback has elapsed AND close > highest(high, opening-range lookback)))
Short: chart bar is confirmed AND (session filter is disabled OR bar time is within the configured session) AND T1 fast EMA < T1 slow EMA AND Chart fast EMA < Chart slow EMA AND close < Chart trend EMA AND close < Chart fast EMA AND RSI < midpoint AND RSI > lower bound AND Short confluence score >= confluence threshold AND (VWAP filter is disabled OR close < VWAP) AND (opening-range filter is disabled OR (opening range is ready after the opening-range lookback has elapsed AND close < lowest(low, opening-range lookback)))
Exit: Long, chart bar is confirmed AND low <= Long trailing stop
Exit: Short, chart bar is confirmed AND high >= Short trailing stop