Calculation: Upper reversal level = close of the most recent confirmed candle with close > open immediately followed by a confirmed candle with close < open, calculated on each timeframe’s bars
Calculation: Lower reversal level = close of the most recent confirmed candle with close < open immediately followed by a confirmed candle with close > open, calculated on each timeframe’s bars
Calculation: Trend state = on each confirmed bar, set to up if close > Upper reversal level, then set to down if close < Lower reversal level; otherwise retain the prior state, initially unset
Calculation: BO state = each new upper or lower reversal level arms that level; on a confirmed bar, if close exceeds the armed upper level, save that level as the latest HH breakout and clear the armed upper level; if close falls below the armed lower level, save it as the latest LL breakout and clear the armed lower level; if both occur, LL is latest; otherwise retain the latest breakout
Long: low > high[2] on a confirmed chart bar
Short: high < low[2] on a confirmed chart bar
Long: Supertrend direction(ATR lookback, multiplier) is up on chart bars
Short: Supertrend direction(ATR lookback, multiplier) is down on chart bars
Long: Trend state = up on confirmed chart bars OR the last completed T1 bar OR the last completed T2 bar; T1 and T2 states are calculated on their own bars and read on chart bars with lookahead off
Short: Trend state = down on confirmed chart bars OR the last completed T1 bar OR the last completed T2 bar; T1 and T2 states are calculated on their own bars and read on chart bars with lookahead off
Long: After the latest HH breakout level changes, low <= that level on its first subsequent touch; check the current chart bar and the latest completed T1 and T2 levels sampled on chart bars with lookahead off, and trigger only once per distinct level
Short: After the latest LL breakout level changes, high >= that level on its first subsequent touch; check the current chart bar and the latest completed T1 and T2 levels sampled on chart bars with lookahead off, and trigger only once per distinct level