Calculation: LongBias = EMA(close, shorter lookback) > EMA(close, longer lookback) OR (EMA(close, shorter lookback) >= EMA(close, longer lookback) AND EMA(OutsideTop10Dominance, index shorter lookback) < EMA(OutsideTop10Dominance, index longer lookback))
Calculation: Alignment = UpUp if EMA(close, shorter lookback) >= EMA(close, longer lookback) AND EMA(OutsideTop10Dominance, index shorter lookback) >= EMA(OutsideTop10Dominance, index longer lookback); UpDown if EMA(close, shorter lookback) >= EMA(close, longer lookback) AND EMA(OutsideTop10Dominance, index shorter lookback) < EMA(OutsideTop10Dominance, index longer lookback); DownUp if EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA(OutsideTop10Dominance, index shorter lookback) > EMA(OutsideTop10Dominance, index longer lookback); otherwise DownDown
Calculation: SwingTrend = -1 if close < most recent PivotLow(low, SwingLength, SwingLength); otherwise 1 if close > most recent PivotHigh(high, SwingLength, SwingLength); otherwise SwingTrend[1]
Calculation: HigherTimeframeTrend = -1 if T1 close < most recent PivotLow(low, SwingLength, SwingLength) on T1 bars; otherwise 1 if T1 close > most recent PivotHigh(high, SwingLength, SwingLength) on T1 bars; otherwise HigherTimeframeTrend[1]; T1 close and pivots are taken from the last completed T1 bar on chart bars
Calculation: OpenReturnPct = 100 * (close - entry price) / entry price for a long position; 100 * (entry price - close) / entry price for a short position
Calculation: LongStop = position side = Long AND OpenReturnPct < StopLossLimit AND EMA(close, shorter lookback) >= EMA(close, longer lookback)
Calculation: ShortStop = position side = Short AND OpenReturnPct < StopLossLimit AND LongBias = false
Calculation: EntryBlock = Long if LongStop = true; Short if ShortStop = true; otherwise none if an entry occurred on the previous bar, else EntryBlock[1]; then a Long EntryBlock becomes none if Alignment[1] in {UpUp, UpDown} AND Alignment != DownUp; a Short EntryBlock becomes none if Alignment[1] in {DownUp, DownDown} AND Alignment != UpDown
Calculation: ScaleOutDone = true if a scale-out exit occurred on the previous bar, or if ScaleOutDone[1] = true and no entry occurred on the previous bar; otherwise false
Calculation: LongTarget(m) = entry-bar close + m * ATR(ATR length) * ATR factor, with ATR taken on the entry bar
Calculation: ShortTarget(m) = entry-bar close - m * ATR(ATR length) * ATR factor, with ATR taken on the entry bar
Calculation: PriorHighSinceEntry = highest high from the bar after the most recent entry bar through the previous bar; negative infinity if none
Calculation: PriorLowSinceEntry = lowest low from the bar after the most recent entry bar through the previous bar; positive infinity if none
Long: position side != Long AND LongBias = true AND SwingTrend = 1 AND RSI(close, RSI length) < RSI overbought level AND EntryBlock != Long
Short: position side != Short AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND SwingTrend = -1 AND RSI(close, RSI length) > RSI oversold level AND EntryBlock != Short
Exit: Long, LongStop = true
Exit: Short, ShortStop = true
Exit: Long, SwingTrend = -1
Exit: Short, SwingTrend = 1
Exit: Long, Alignment[1] = UpUp AND Alignment = UpDown AND OpenReturnPct > ScaleOutMinReturn AND ScaleOutDone = false
Exit: Short, Alignment[1] = DownDown AND Alignment != DownDown AND LongBias = false AND OpenReturnPct > ScaleOutMinReturn AND ScaleOutDone = false
Exit: Long, high > LongTarget(nearer target multiple) AND PriorHighSinceEntry <= LongTarget(nearer target multiple)
Exit: Long, high > LongTarget(middle target multiple) AND PriorHighSinceEntry <= LongTarget(middle target multiple)
Exit: Long, high > LongTarget(farther target multiple) AND PriorHighSinceEntry <= LongTarget(farther target multiple)
Exit: Short, low < ShortTarget(nearer target multiple) AND PriorLowSinceEntry >= ShortTarget(nearer target multiple)
Exit: Short, low < ShortTarget(middle target multiple) AND PriorLowSinceEntry >= ShortTarget(middle target multiple)
Exit: Short, low < ShortTarget(farther target multiple) AND PriorLowSinceEntry >= ShortTarget(farther target multiple)
Long: SwingTrend = 1
Short: SwingTrend = -1
Long: HigherTimeframeTrend = 1
Short: HigherTimeframeTrend = -1
Long: EMA(close, shorter lookback) >= EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)