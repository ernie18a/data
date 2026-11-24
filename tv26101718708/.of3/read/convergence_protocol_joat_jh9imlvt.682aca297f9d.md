Calculation: Center = SMA(EMA(close, center length), center length)
Calculation: Band Width = SMA(EMA(high - low, band width length), band width length)
Calculation: Last Swing High = most recent PivotHigh(high, pivot length, pivot length) value
Calculation: Previous Swing High = second most recent PivotHigh(high, pivot length, pivot length) value
Calculation: Last Swing Low = most recent PivotLow(low, pivot length, pivot length) value
Calculation: Previous Swing Low = second most recent PivotLow(low, pivot length, pivot length) value
Calculation: Higher High = Last Swing High > Previous Swing High
Calculation: Lower High = Last Swing High < Previous Swing High
Calculation: Higher Low = Last Swing Low > Previous Swing Low
Calculation: Lower Low = Last Swing Low < Previous Swing Low
Calculation: Bull Count = count of true among: close > Center + Band Width; close > Center + Band Width * outer band multiple; Higher High; Higher Low
Calculation: Bear Count = count of true among: close < Center - Band Width; close < Center - Band Width * outer band multiple; Lower Low; Lower High
Calculation: Trend Regime = 1 if Center > Center[1] AND Bull Count >= regime count threshold; -1 if Center < Center[1] AND Bear Count >= regime count threshold; 0 otherwise
Calculation: ATR Ratio = ATR(atr length) / ATR(slow atr length)
Calculation: Volatility Expansion = ATR Ratio > volatility ratio threshold AND EMA(ATR Ratio - 1, volatility osc length) > SMA(EMA(ATR Ratio - 1, volatility osc length), volatility signal length)
Calculation: Compression = ATR(atr length) < ATR(slow atr length) * compression factor AND ATR(atr length) < SMA(ATR(atr length), atr average length)
Calculation: Compression Release = NOT Compression AND Compression[1]
Calculation: Signed Volume = volume * sign(close - open)
Calculation: Delta Spread = EMA(Signed Volume, delta fast length) - EMA(Signed Volume, delta slow length)
Calculation: Delta Oscillator = Delta Spread / MAX(Percentile(ABS(Delta Spread), delta reference window, delta reference percentile), delta floor)
Calculation: Delta Bullish = Delta Oscillator > delta threshold AND Delta Oscillator > EMA(Delta Oscillator, delta signal length)
Calculation: Delta Bearish = Delta Oscillator < -delta threshold AND Delta Oscillator < EMA(Delta Oscillator, delta signal length)
Calculation: Bullish Break State = NOT close crosses below Last Swing Low AND (close crosses above Last Swing High OR Bullish Break State[1])
Calculation: Bearish Break State = close crosses below Last Swing Low OR (Bearish Break State[1] AND NOT close crosses above Last Swing High)
Calculation: Bullish Sweep = low < Last Swing Low - ATR(atr length) * sweep ATR multiple AND close > Last Swing Low
Calculation: Bearish Sweep = high > Last Swing High + ATR(atr length) * sweep ATR multiple AND close < Last Swing High
Calculation: Long Confluence = count of true among: Trend Regime = 1; Higher High AND Higher Low; Volatility Expansion; NOT Compression; Delta Bullish; Bullish Break State; Bullish Sweep
Calculation: Short Confluence = count of true among: Trend Regime = -1; Lower High AND Lower Low; Volatility Expansion; NOT Compression; Delta Bearish; Bearish Break State; Bearish Sweep
Calculation: Near Center = ABS(close - Center) < Band Width * near center multiple
Calculation: Risk Distance = ATR(atr length) at entry * stop ATR multiple
Calculation: Highest High Since Entry = highest high of bars after entry bar through current bar
Calculation: Lowest Low Since Entry = lowest low of bars after entry bar through current bar
Calculation: TP1 Reached Long = Highest High Since Entry >= entry price + Risk Distance * TP1 multiple
Calculation: TP1 Reached Short = Lowest Low Since Entry <= entry price - Risk Distance * TP1 multiple
Calculation: Trail Distance = ATR(atr length) on the bar TP1 is first reached * trail ATR multiple
Long: Position side = flat AND (NOT volume gate enabled OR Volatility Expansion) AND Long Confluence >= minimum confluence score AND Trend Regime = 1
Long: Position side = flat AND pullback entries enabled AND Trend Regime = 1 AND Near Center AND low <= Center + Band Width * pullback touch multiple AND close > Center AND Delta Bullish AND (NOT volume gate enabled OR Volatility Expansion)
Long: Position side = flat AND squeeze breakout entries enabled AND Compression Release AND Trend Regime = 1 AND Delta Bullish
Long: Position side = flat AND Delta Spread crosses above 0 AND Trend Regime = 1 AND NOT Compression AND (NOT volume gate enabled OR Volatility Expansion)
Long: Position side = flat AND sweep reversal entries enabled AND Bullish Sweep AND Delta Bullish
Long: Delta Spread crosses above 0 AND Trend Regime = 1
Short: Position side = flat AND (NOT volume gate enabled OR Volatility Expansion) AND Short Confluence >= minimum confluence score AND Trend Regime = -1
Short: Position side = flat AND pullback entries enabled AND Trend Regime = -1 AND Near Center AND high >= Center - Band Width * pullback touch multiple AND close < Center AND Delta Bearish AND (NOT volume gate enabled OR Volatility Expansion)
Short: Position side = flat AND squeeze breakout entries enabled AND Compression Release AND Trend Regime = -1 AND Delta Bearish
Short: Position side = flat AND Delta Spread crosses below 0 AND Trend Regime = -1 AND NOT Compression AND (NOT volume gate enabled OR Volatility Expansion)
Short: Position side = flat AND sweep reversal entries enabled AND Bearish Sweep AND Delta Bearish
Short: Delta Spread crosses below 0 AND Trend Regime = -1
Exit: long, low <= entry price - Risk Distance AND (NOT trailing stop enabled OR NOT TP1 Reached Long[1])
Exit: long, TP1 Reached Long AND NOT TP1 Reached Long[1]
Exit: long, high >= entry price + Risk Distance * TP2 multiple AND (NOT trailing stop enabled OR NOT TP1 Reached Long[1])
Exit: long, low <= Highest High Since Entry - Trail Distance AND trailing stop enabled AND TP1 Reached Long
Exit: long, Trend Regime = -1
Exit: short, high >= entry price + Risk Distance AND (NOT trailing stop enabled OR NOT TP1 Reached Short[1])
Exit: short, TP1 Reached Short AND NOT TP1 Reached Short[1]
Exit: short, low <= entry price - Risk Distance * TP2 multiple AND (NOT trailing stop enabled OR NOT TP1 Reached Short[1])
Exit: short, high >= Lowest Low Since Entry + Trail Distance AND trailing stop enabled AND TP1 Reached Short
Exit: short, Trend Regime = 1