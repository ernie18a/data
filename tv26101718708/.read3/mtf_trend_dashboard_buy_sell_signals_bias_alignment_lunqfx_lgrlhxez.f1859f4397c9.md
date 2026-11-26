Calculation: Trend(structure swing length) = -1 if close < most recent PivotLow(structure swing length); otherwise 1 if close > most recent PivotHigh(structure swing length); otherwise Trend[1]
Calculation: Break(side) = close above most recent PivotHigh(chart swing length) when side is up, or below most recent PivotLow(chart swing length) when side is down, and no close from that pivot's confirmation bar through the previous bar was beyond it
Calculation: LongStop = min(LowAnchor - ATR(atr length) * stop buffer, close - ATR(atr length) * minimum stop), where LowAnchor = min(most recent PivotLow(chart swing length), low) if a PivotLow exists, else lowest(low, fallback lookback)
Calculation: ShortStop = max(HighAnchor + ATR(atr length) * stop buffer, close + ATR(atr length) * minimum stop), where HighAnchor = max(most recent PivotHigh(chart swing length), high) if a PivotHigh exists, else highest(high, fallback lookback)
Calculation: Count(c, S) = number of dashboard timeframes T in S for which c holds, where S is higher (T strictly above the chart timeframe) or used (T at or above the chart timeframe)
Calculation: HigherAgree(v) = 1 if Count(Trend(structure swing length, T, last completed bar) = v, higher) > Count(Trend(structure swing length, T, last completed bar) = -v, higher) AND Count(Trend(structure swing length, T, last completed bar) = v, higher) >= min(required agreement count, Count(true, higher)); otherwise 0
Calculation: AllUsed(v) = 1 if Count(Trend(structure swing length, T, last completed bar) = v, used) = Count(true, used) AND Count(true, used) > 0; otherwise 0
Long: Break(up) = true AND HigherAgree(1) = 1 AND close - LongStop(current bar) <= maximum stop * ATR(atr length) AND position side is not long
Short: Break(down) = true AND HigherAgree(-1) = 1 AND ShortStop(current bar) - close <= maximum stop * ATR(atr length) AND position side is not short
Long: Count(Trend(structure swing length, T, last completed bar) = 1, used) > Count(Trend(structure swing length, T, last completed bar) = -1, used)
Short: Count(Trend(structure swing length, T, last completed bar) = -1, used) > Count(Trend(structure swing length, T, last completed bar) = 1, used)
Long: T1 at or above chart timeframe AND Trend(structure swing length, T1, last completed bar) = 1
Long: T2 at or above chart timeframe AND Trend(structure swing length, T2, last completed bar) = 1
Long: T3 at or above chart timeframe AND Trend(structure swing length, T3, last completed bar) = 1
Long: T4 at or above chart timeframe AND Trend(structure swing length, T4, last completed bar) = 1
Long: T5 at or above chart timeframe AND Trend(structure swing length, T5, last completed bar) = 1
Long: T6 at or above chart timeframe AND Trend(structure swing length, T6, last completed bar) = 1
Short: T1 at or above chart timeframe AND Trend(structure swing length, T1, last completed bar) = -1
Short: T2 at or above chart timeframe AND Trend(structure swing length, T2, last completed bar) = -1
Short: T3 at or above chart timeframe AND Trend(structure swing length, T3, last completed bar) = -1
Short: T4 at or above chart timeframe AND Trend(structure swing length, T4, last completed bar) = -1
Short: T5 at or above chart timeframe AND Trend(structure swing length, T5, last completed bar) = -1
Short: T6 at or above chart timeframe AND Trend(structure swing length, T6, last completed bar) = -1
Long: AllUsed(1) crosses above 0
Short: AllUsed(-1) crosses above 0
Long: HigherAgree(1) = 1 AND position side is flat
Short: HigherAgree(-1) = 1 AND position side is flat
Exit: long, low <= LongStop(entry bar) OR high >= entry price + second target multiple * (entry price - LongStop(entry bar))
Exit: short, high >= ShortStop(entry bar) OR low <= entry price - second target multiple * (ShortStop(entry bar) - entry price)