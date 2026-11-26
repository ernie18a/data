Calculation: Swing = accepted alternating swing points, evaluated on each chart bar. PivotHigh(high, left bars, right bars) at bar now-right bars is an accepted top if the last accepted swing is not a top AND (no bottom accepted yet OR that pivot high - last bottom price >= swing multiple * ATR(swing ATR length) at now). PivotLow(low, left bars, right bars) at bar now-right bars is an accepted bottom if the last accepted swing is not a bottom AND (no top accepted yet OR last top price - that pivot low >= swing multiple * ATR(swing ATR length) at now). While the last accepted swing is a top, a higher pivot high replaces the last top price; while it is a bottom, a lower pivot low replaces the last bottom price. Previous top price = last top price as it was before the most recent accepted top; previous bottom price = last bottom price as it was before the most recent accepted bottom. Outputs: event on this bar (top, bottom, or none), last top price, previous top price, last bottom price, previous bottom price
Calculation: TFEMA(lookback, T) = if smoothing is on: EMA(close, lookback * max(1, round(T / chart bar duration))) on chart bars; if smoothing is off: EMA(close, lookback) on T bars, last completed T bar
Calculation: EMATrend = sign(TFEMA(shorter lookback, T3) - TFEMA(longer lookback, T4))
Calculation: HTFTrend = sign(close - EMA(close, HTF EMA lookback) on T2 bars, last completed T2 bar)
Calculation: VWAPTrend = sign(close - VWAP(price source, session))
Calculation: Momentum = sign(RSI(close, RSI lookback) - RSI level)
Calculation: StructureTrend = +1 if Swing last top price > Swing previous top price AND Swing last bottom price > Swing previous bottom price; -1 if Swing last top price < Swing previous top price AND Swing last bottom price < Swing previous bottom price; otherwise 0
Calculation: PrevDayTrend = sign(close - close of last completed T5 bar)
Calculation: Bias = EMATrend + HTFTrend + VWAPTrend + Momentum + StructureTrend + PrevDayTrend
Calculation: FVG = on the first chart bar of each new T1 bar, with c3 = last completed T1 bar and c1 = T1 bar two bars before c3: type = bullish if low(c3) > high(c1) AND low(c3) - high(c1) >= gap multiple * ATR(FVG ATR length) on T1 at c3; type = bearish if high(c3) < low(c1) AND low(c1) - high(c3) >= gap multiple * ATR(FVG ATR length) on T1 at c3; otherwise type = none; a bullish FVG has bottom = high(c1) and top = low(c3); a bearish FVG has top = low(c1) and bottom = high(c3); type = none on all other chart bars
Short: Swing event = top
Long: Swing event = bottom
Long: EMATrend > 0
Short: EMATrend < 0
Long: HTFTrend > 0
Short: HTFTrend < 0
Long: VWAPTrend > 0
Short: VWAPTrend < 0
Long: Momentum > 0
Short: Momentum < 0
Long: StructureTrend > 0
Short: StructureTrend < 0
Long: PrevDayTrend > 0
Short: PrevDayTrend < 0
Long: Bias > 0
Short: Bias < 0
Long: FVG type = bullish
Short: FVG type = bearish
Short: close < bottom of a bullish FVG formed at or before this bar, where no bar after its formation and before this bar had low <= that bottom
Long: close > top of a bearish FVG formed at or before this bar, where no bar after its formation and before this bar had high >= that top